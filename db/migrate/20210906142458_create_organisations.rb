class CreateOrganisations < ActiveRecord::Migration[5.2]
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :phone_no
      t.string :email
      t.text :help_desk_info
      t.string :customer_contact
      t.text :additional_info

      t.timestamps
    end
  end
end
