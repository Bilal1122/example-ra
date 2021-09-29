class CreateUserTrackers < ActiveRecord::Migration[5.2]
  def change
    create_table :user_trackers do |t|
      t.integer :user_id
      t.string :ip_address

      t.timestamps
    end
  end
end
