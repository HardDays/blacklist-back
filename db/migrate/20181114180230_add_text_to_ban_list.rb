class AddTextToBanList < ActiveRecord::Migration[5.2]
  def change
    add_column :ban_lists, :text, :string
  end
end
