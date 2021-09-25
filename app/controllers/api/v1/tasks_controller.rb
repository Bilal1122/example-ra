class Api::V1::TasksController < Api::V1::ApiController
  before_action :authenticate

  def index
    tasks = Task.all
    tasks = tasks.as_json(
      only: [:id, :title, :description, :task_type],
      include: [
        created_by: {methods: [:full_name], only: [:email]},
      ]
    )
    json_success("Fetched.", tasks);
  end

  def create
    task = Task.new(task_params)
    if Task.where(title: task.title, task_type: task.task_type).blank?
      task.created_by_id = @current_user.id
      if task.save
        task = task.as_json(
          only: [:id, :title, :description, :task_type],
          include: [
            created_by: {methods: [:full_name], only: [:email]},
          ]
        )
        json_success("Task created Successfully.", task);
      else
        json_bad_request(task.errors.full_messages.to_sentence)
      end
    else
      json_bad_request("Task with same title and type exist.")
    end
  end

  def update
    task = Task.find_by(id: params[:id])
    if task
      task.assign_attributes(task_params)
      # if Task.where(title: task.title, task_type: task.task_type).blank?
      task.created_by_id = @current_user.id
      if task.save
        task = task.as_json(
          only: [:id, :title, :description, :task_type],
          include: [
            created_by: {methods: [:full_name], only: [:email]},
          ]
        )
        json_success("Task created Successfully.", task);
      else
        json_bad_request(task.errors.full_messages.to_sentence)
      end
    else
      json_bad_request("Task not found.")
    end
  end

  def destroy
    task = Task.find_by(id: params[:id])
    if task.present?
      OrganisationTask.where(task_id: task.id).delete_all
      task.delete
      json_success("Task deleted Successfully.");
    else
      json_bad_request("Task not found.")
    end
  end

  private
  def task_params
    params.require(:task).permit(
      "title",
      "description",
      "task_type"
    )
  end
end
