class Api::V1::SessionsController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token, only: [:create]
  protect_from_forgery with: :null_session, only: [:create]
  skip_before_action :authenticate, only: [:create]

  def create
    user = User.find_by_email(params[:email])
    if user
      if user.valid_password?(params[:password])
        if !user.blocked?
          sign_in(:user, user)
          response = user.as_json(
            only: [:firstname, :lastname, :email, :authentication_token],
            include: [role_info: {only: [:is_admin, :is_consultant]}]
          )
          user.update(failed_attempts: 0)
          user.user_trackers.create(ip_address: user.current_sign_in_ip)
          # user.user_trackers.where('created_at < ?', (Time.now - 1.month)).delete_all
          json_success("Session created!", response);
        else
          if user.failed_attempts.to_i >= 3
            json_unauthorized("You have been blocked due to multiple incorrect password attempts. please contact admin at sas@sas.com")
          else
            json_unauthorized("You have been blocked by the admin. please contact admin at sas@sas.com")
          end
        end
      else
        if !user.blocked?
          failed_attempts = user.failed_attempts.to_i + 1
          user.update(failed_attempts: failed_attempts, blocked: failed_attempts >= 3)
        end
        if user.failed_attempts.to_i >= 3
          json_unauthorized("You have been blocked due to multiple incorrect password attempts. please contact admin at sas@sas.com")
        else
          json_unauthorized("wrong email or password")
        end
      end
    else
      json_unauthorized("wrong email or password")
    end
  end

  def log_out
    sign_out @current_user
    json_success("User Session Deleted!");
  end

end
