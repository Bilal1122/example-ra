class AddActiveToOrganisations < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :active, :boolean, default: false
  end
end
