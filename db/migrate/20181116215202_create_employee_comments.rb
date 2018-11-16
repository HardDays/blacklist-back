class CreateEmployeeComments < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_comments do |t|
      t.integer :user_id
      t.integer :comment_type
      t.string :text

      t.timestamps
    end
  end
end
