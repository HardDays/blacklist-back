class AddSecurityFileToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :security_file_id, :integer
    add_column :payments, :expires_at, :datetime
  end
end
