class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :name
      t.string :period
      t.string :position
      t.string :description
      t.integer :employee_id

      t.timestamps
    end
  end
end
