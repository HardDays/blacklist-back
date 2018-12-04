class RemoveIsPayedFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :is_payed, :boolean
  end
end
