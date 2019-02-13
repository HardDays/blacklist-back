class AddUserToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :user_id, :integer
    add_column :payments, :payment_type, :integer
    add_column :payments, :payment_date, :datetime
    remove_column :payments, :subscription_id, :integer
  end
end
