class CreateUserRoleInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :user_role_infos do |t|
      t.integer :user_id
      t.boolean :is_admin, default: false
      t.boolean :is_consultant, default: false

      t.timestamps
    end
  end
end
