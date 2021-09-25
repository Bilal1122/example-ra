class UserMailer < ApplicationMailer
  def account_setup_mail(user, temporary_password)
    @user = user
    user_role = user.role_info
    @role_type = user_role.is_admin == true ? 'Admin' : 'Consultant'
    @temporary_password = temporary_password
    mail to: user.email, subject: "You have been invited to join RA!"
  end
end
