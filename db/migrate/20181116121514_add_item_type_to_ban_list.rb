class AddItemTypeToBanList < ActiveRecord::Migration[5.2]
  def change
    add_column :ban_lists, :item_type, :integer, default: 1
  end
end
