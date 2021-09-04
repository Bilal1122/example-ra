class Api::V1::UsersController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  # protect_from_forgery with: :null_session

  def create
    organisation_ids = params['organisations']
    user = User.new(user_params)
    temp_password = Devise.friendly_token
    user.password = temp_password
    user.password_confirmation = temp_password
    if user.save
      user.create_role_info(is_admin: params['is_admin'], is_consultant: params['is_admin'])
      if organisation_ids
        organisation_ids.each do |org_id|
          user.user_organisations.create(organisation_id: org_id)
        end
      end
      json_success("User created successfully.");
    else
      json_bad_request(user.errors.full_messages.to_sentence)
    end
  end

  def forgot_password
    user = User.find_by_email(params[:email])
    if user.present?
      user.send_reset_password_instructions
      json_success("Password reset email sent!");
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
        json_success("Password reset successfully", response);
      else
        json_bad_request(user.errors.full_messages.to_sentence)
      end
    else
      json_unauthorized("Reset token expired")
    end
  end

  private
  def user_params
    params.require(:user).permit(
      :firstname,
      :lastname,
      :email,
      :created_by_id
    )
  end
end
