class AddStatusToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :status, :integer
  end
end
