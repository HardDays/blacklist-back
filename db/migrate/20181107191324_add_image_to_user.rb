class AddImageToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :image_id, :integer
    remove_column :images, :user_id, :integer
  end
end
