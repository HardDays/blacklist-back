class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.datetime :last_payment_date

      t.timestamps
    end
  end
end
