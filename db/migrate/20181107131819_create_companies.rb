class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.integer :user_id
      t.string :name
      t.string :description
      t.string :contacts
      t.string :address

      t.timestamps
    end
  end
end
