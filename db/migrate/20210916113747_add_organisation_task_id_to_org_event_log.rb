class AddOrganisationTaskIdToOrgEventLog < ActiveRecord::Migration[5.2]
  def change
    add_column :org_event_logs, :organisation_task_id, :integer
  end
end
