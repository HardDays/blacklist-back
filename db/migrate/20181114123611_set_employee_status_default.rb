class SetEmployeeStatusDefault < ActiveRecord::Migration[5.2]
  def change
    change_column :employees, :status, :integer, default: 0
  end
end
