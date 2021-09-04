class CreateUserOrganisations < ActiveRecord::Migration[5.2]
  def change
    create_table :user_organisations do |t|
      t.integer :user_id
      t.integer :organisation_id

      t.timestamps
    end
  end
end
