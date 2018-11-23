class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.integer :status, default: 0
      t.integer :invid
      t.integer :price
      t.integer :subscription_id

      t.timestamps
    end
  end
end
