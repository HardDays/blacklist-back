class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :second_name
      t.datetime :birthday
      t.integer :gender
      t.string :education
      t.string :education_year
      t.string :contacts
      t.string :skills
      t.integer :experience
      t.integer :status
      t.integer :user_id
      t.string :position

      t.timestamps
    end
  end
end
