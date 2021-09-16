class CreateOrganisationTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :organisation_tasks do |t|
      t.integer :organisation_id
      t.integer :task_id
      t.date :start_at
      t.date :end_at
      t.string :status

      t.timestamps
    end
  end
end
