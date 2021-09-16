class AddColumnsToOrganisations < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :os, :string
    add_column :organisations, :cpu, :string
    add_column :organisations, :ram, :string
    add_column :organisations, :disk, :string
    add_column :organisations, :logical_processors, :string
    add_column :organisations, :cores, :string
  end
end
