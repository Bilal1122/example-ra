class CreateOrgEventLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :org_event_logs do |t|
      t.integer :organisation_id
      t.string :title
      t.text :description
      t.string :attachment
      t.text :data
      t.integer :created_by_id

      t.timestamps
    end
  end
end
