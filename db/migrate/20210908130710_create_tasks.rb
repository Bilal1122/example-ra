class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.string :type
      t.integer :created_by_id

      t.timestamps
    end
  end
end
