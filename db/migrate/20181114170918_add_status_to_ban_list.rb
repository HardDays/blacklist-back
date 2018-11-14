class AddStatusToBanList < ActiveRecord::Migration[5.2]
  def change
    add_column :ban_lists, :status, :integer, default: 1
  end
end
