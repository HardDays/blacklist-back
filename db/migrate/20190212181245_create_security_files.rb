class CreateSecurityFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :security_files do |t|
      t.string :base64

      t.timestamps
    end
  end
end
