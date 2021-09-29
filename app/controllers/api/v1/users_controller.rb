class Api::V1::UsersController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate, only: [:forgot_password, :reset_password]

  def index
    response = @current_user.as_json(
      only: [:id, :firstname, :lastname, :email],
      include: [role_info: {only: [:is_admin, :is_consultant]}]
    )
    json_success("Fetched.", response);
  end

  def get_list
    response = User.order(created_at: :asc).as_json(
      only: [:id, :firstname, :lastname, :email, :blocked, :sign_in_count, :last_sign_in_at],
      include: [role_info: {only: [:is_admin, :is_consultant]}]
    )
    json_success("Fetched.", response);
  end

  def show
    user = User.find_by(id: params[:id])
    response = user.as_json(
      only: [:firstname, :lastname, :email],
      include: [
        role_info: {only: [:is_admin, :is_consultant]},
        organisations: {only: [:id, :name]},
        user_trackers: {only: [:ip_address, :created_at]}
      ],
    )
    json_success("Fetched.", response);
  end

  def create
    organisation_ids = params['organisations']
    user = User.new(user_params)
    temp_password = Devise.friendly_token
    user.password = temp_password
    user.password_confirmation = temp_password
    user.created_by_id = @current_user.id
    if user.save
      user.create_role_info(is_admin: params['is_admin'], is_consultant: params['is_consultant'])
      if organisation_ids
        organisation_ids.each do |org_id|
          create_event_log(user, org_id)
          user.user_organisations.create(organisation_id: org_id)
        end
      end
      UserMailer.account_setup_mail(user, temp_password).deliver_later
      json_success("User created successfully.");
    else
      json_bad_request(user.errors.full_messages.to_sentence)
    end
  end

  def update
    user = User.find_by(id: params[:id])
    if user
      if params[:oldPassword].present? && !user.valid_password?(params[:oldPassword])
        json_bad_request("Wrong old password.")
        return false
      end
      
      if params[:password] && params[:passwordConfirmation]
        user.password = params[:password]
        user.password_confirmation = params[:passwordConfirmation]
      end

      user_role = user.role_info
      if user.update(user_params)
        if user_params[:blocked] == false
          user.update(failed_attempts: 0)
        end
        user_role.is_admin = params['is_admin'] if !params['is_admin'].nil?
        user_role.is_consultant = params['is_consultant'] if !params['is_consultant'].nil?
        user_role.save
        organisation_ids = params['organisations']
        if !user_role.is_consultant
          user.user_organisations.delete_all
        end
        if organisation_ids && user_role.is_consultant
          organisation_ids.each do |org_id|
            create_event_log(user, org_id)
            user.user_organisations.create(organisation_id: org_id)
          end
        end
        user.user_organisations.where(organisation_id: params['toRemoveOrganisations']).delete_all
        organisation_ids_to_delete = params['delete_organisations']
        user.user_organisations.where(organisation_id: params['delete_organisations']).delete_all

        json_success("User updated successfully.");
      else
        json_bad_request("Something wend wrong")
      end

    else
      json_bad_request("User not found")
    end
  end

  def forgot_password
    user = User.find_by_email(params[:email])
    if user.present?
      if !user.blocked?
        user.send_reset_password_instructions
        json_success("Password reset email sent!");
      else
        json_bad_request("User with email '#{user.email}' is blocked.");
      end
    else
      json_not_found("Email not found")
    end
  end

  def reset_password
    reset_password_token = params['reset_password_token']
    hashed_token = Devise.token_generator.digest(User, :reset_password_token, reset_password_token)
    user = User.find_by(reset_password_token: hashed_token)
    if user.present?
      user.authentication_token = nil
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
      if user.save
        response = user.as_json(
          only: [:firstname, :lastname, :email, :authentication_token],
          include: [role_info: {only: [:is_admin, :is_consultant]}]
        )
        json_success("Password reset successfully.", response);
      else
        json_bad_request(user.errors.full_messages.to_sentence)
      end
    else
      json_unauthorized("Reset token expired")
    end
  end

  def confirm_account
    user = User.find_by_email(params[:email])
    if user
      if user.valid_password?(params[:temp_password])
        user.password = params[:password]
        user.password_confirmation = params[:password_confirmation]
        if user.save
          json_success("Account updated successfully.", response);
        else
          json_bad_request(user.errors.full_messages.to_sentence)
        end
      else
        json_unauthorized("Wrong or expired temporary password.")
      end
    else
      json_unauthorized("User not found.")
    end
  end

  private
  def user_params
    params.require(:user).permit(
      :firstname,
      :lastname,
      :email,
      :blocked
    )
  end

  def create_event_log(user, org_id)
    OrgEventLog.create(
      organisation_id: org_id,
      title: "#{user.full_name} added to organisation as a consultant.",
      created_by_id: @current_user.id,
      data: {user_id: user.id}.to_json
    )
  end
end
