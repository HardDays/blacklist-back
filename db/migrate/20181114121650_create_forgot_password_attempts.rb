class CreateForgotPasswordAttempts < ActiveRecord::Migration[5.2]
  def change
    create_table :forgot_password_attempts do |t|
      t.integer :user_id
      t.integer :attempt_count

      t.timestamps
    end
  end
end
