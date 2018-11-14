class CreateEmployeeOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_offers do |t|
      t.integer :employee_id
      t.string :position
      t.string :description
      t.integer :company_id

      t.timestamps
    end
  end
end
