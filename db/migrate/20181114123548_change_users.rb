class ChangeUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at

    add_column :users, :is_payed, :boolean, default: false
  end
end
