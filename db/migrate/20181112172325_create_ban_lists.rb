class CreateBanLists < ActiveRecord::Migration[5.2]
  def change
    create_table :ban_lists do |t|
      t.string :name
      t.string :description
      t.string :addresses

      t.timestamps
    end
  end
end
