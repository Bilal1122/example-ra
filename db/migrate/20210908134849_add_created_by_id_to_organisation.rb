class AddCreatedByIdToOrganisation < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :created_by_id, :integer
  end
end
