class CreateSecurityRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :security_requests do |t|
      t.string :base64
      t.integer :user_id

      t.timestamps
    end
  end
end
