class CreateTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :tokens do |t|
      t.integer :user_id
      t.string :info
      t.string :token

      t.timestamps
    end
  end
end
