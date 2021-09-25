class AddOrderToUserOrganisations < ActiveRecord::Migration[5.2]
  def change
    add_column :user_organisations, :order, :integer
  end
end
