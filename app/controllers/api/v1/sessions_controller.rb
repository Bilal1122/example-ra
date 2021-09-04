class Api::V1::SessionsController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session

  def create
    user = User.find_by_email(params[:email])
    if user && !user.blocked?
      if user && user.valid_password?(params[:password])
        response = user.as_json(
          only: [:firstname, :lastname, :email, :authentication_token],
          include: [role_info: {only: [:is_admin, :is_consultant]}]
        )
        json_success("Session created!", response);
      else
        json_unauthorized("wrong email or password")
      end
    else
      json_unauthorized("You have been blocked by the admin. please contact admin at sas@sas.com")
    end
  end

  def destroy
  end

end