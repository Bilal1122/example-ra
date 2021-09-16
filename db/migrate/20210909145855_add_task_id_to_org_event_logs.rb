class AddTaskIdToOrgEventLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :org_event_logs, :task_id, :integer
  end
end
