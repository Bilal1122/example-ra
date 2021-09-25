class TaskMailer < ApplicationMailer
  def send_mail(consultant, organisation, assigned_by)
    @organisation = organisation
    @tasks = organisation.tasks
    @assigned_by = assigned_by
    mail to: consultant.email, subject: "A new customers has been assigned to you!"
  end
end
