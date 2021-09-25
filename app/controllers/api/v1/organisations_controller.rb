class Api::V1::OrganisationsController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session
  before_action :authenticate
  
  def index
    organisations = @current_user.is_admin ? Organisation.all : @current_user.organisations
    resp = organisations.as_json(
      include: [
        organisation_tasks: {only: [:id, :start_at, :end_at, :status], methods: [:task_status, :task_info, :log_event]}
      ]
    )
    json_success("Fetched.", resp);
  end

  def get_org_list
    organisations = Organisation.order(created_at: :asc).select(:id, :name, :created_by_id, :created_at, :active)
    organisations = organisations.as_json(
      only: [:id, :name, :created_at, :active],
      include: [
        consultants: {methods: [:full_name], only: [:email]},
        created_by: {methods: [:full_name], only: [:email]}
      ]
    )
    json_success("Fetched.", organisations);
  end

  def show
    organisation = Organisation.find_by(id: params[:id])
    if organisation
      organisation = organisation.as_json(
        include: [
          consultants: {methods: [:full_name], only: [:id]},
          created_by: {methods: [:full_name], only: [:email]},
          tasks: {only: [:id, :title, :description, :task_type]},
          org_event_logs: {}
        ]
      )
      json_success("Fetched.", organisation);
    else
      json_bad_request("Organisation not found.")
    end
  end

  def create
    organisation = Organisation.new(organisation_params)
    if Organisation.find_by_name(organisation.name).blank?
      organisation.created_by_id = @current_user.id
      if organisation.save
        params[:add_task_ids].each do |id|
          organisation.organisation_tasks.create(task_id: id)
        end
        params[:consultants].each_with_index do |user_id, index|
          consultant = User.find_by(id: user_id)
          organisation.user_organisations.create(user_id: user_id, order: index)
          # logs
          create_event_log(consultant, organisation)
          # send email
          TaskMailer.send_mail(consultant, organisation, @current_user).deliver_later
        end
        json_success("Organisation saved successfully", organisation);
      else
        json_bad_request(user.errors.full_messages.to_sentence)
      end
    else
      json_bad_request("Organisation with name #{organisation.name} already exist.")
    end
  end

  def update
    organisation = Organisation.find_by(id: params[:id])
    if organisation
      organisation.assign_attributes(organisation_params)
      if organisation.save
        params[:add_task_ids] && params[:add_task_ids].each do |id|
          organisation.organisation_tasks.create(task_id: id)
        end
        organisation.organisation_tasks.where(task_id: params[:remove_task_ids]).delete_all

        user_orgs = organisation.user_organisations.where.not(user_id: nil).order(order: :asc)
        if params[:consultants]
          binding.pry
          first_id = params[:consultants][0]
          second_id = params[:consultants][1]
          if user_orgs.first && first_id && user_orgs.first.user_id != first_id
            # removed user
            create_event_log(user_orgs.first.user, organisation, false)
            # update user
            user_orgs.first.update_attributes(user_id: first_id)
            # add user
            create_event_log(user_orgs.first.user, organisation, false)
            # mail
            TaskMailer.send_mail(user_orgs.first.user, organisation, @current_user).deliver_later
          end
          if user_orgs.second && second_id && user_orgs.second.user_id != second_id
            # removed user
            # create_event_log(user_orgs.second.user, organisation, false)
            # update user
            user_orgs.second.update_attributes(user_id: second_id)
            # add user
            create_event_log(user_orgs.second.user, organisation, false)
            # mail
            TaskMailer.send_mail(user_orgs.second.user, organisation, @current_user).deliver_later
          end
        end
        json_success("Organisation updated successfully", organisation);
      else
        json_bad_request(user.errors.full_messages.to_sentence)
      end
    else
      json_bad_request("Organisation with id: #{params[:id]} not found.")
    end
  end

  def complete_task
    event = OrgEventLog.new(event_log)
    task = Task.find_by(id: event.task_id)
    event.title = "#{@current_user.full_name} has completed #{task.task_type} task with title - #{task.title}."
    event.data = {user_id: @current_user.id}.to_json
    event.created_by_id = @current_user.id
    if event.save
      org_task = OrganisationTask.find_by(id: event.organisation_task_id)
      org_task.update(status: 'completed')
      json_success("event logged successfully", event);
    else
      json_bad_request(event.errors.full_messages.to_sentence)
    end
  end
 
  private
  def organisation_params
    params.require(:organisation).permit(
      "name",
      "phone_no",
      "email",
      "help_desk_info",
      "customer_contact",
      "additional_info",
      "active",
      "os",
      "cpu",
      "ram",
      "disk",
      "logical_processors",
      "cores",
      "stack_name",
      "topology"
    )
  end

  def event_log
    params.require(:event).permit(
      "organisation_task_id",
      "organisation_id",
      "description",
      # "attachment",
      "task_id"
    )
  end

  def create_event_log(user, org, add=true)
    OrgEventLog.create(
      organisation_id: org.id,
      title: add ? "#{user.full_name} added to organisation as a consultant by #{@current_user.full_name}." : "#{user.full_name} removed from organisation by #{@current_user.full_name}.",
      created_by_id: @current_user.id,
      data: {user_id: user.id}.to_json
    )
  end
end
