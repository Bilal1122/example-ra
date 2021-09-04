class ChangeDefault < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :blocked, :boolean, default: false
  end
end
