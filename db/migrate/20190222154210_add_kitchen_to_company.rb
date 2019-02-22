class AddKitchenToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :kitchen, :string
    add_column :companies, :work_time, :string
  end
end
