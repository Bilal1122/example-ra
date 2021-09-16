class AddStackAndTolologyToOrganisations < ActiveRecord::Migration[5.2]
  def change
    add_column :organisations, :stack_name, :string
    add_column :organisations, :topology, :string
  end
end
