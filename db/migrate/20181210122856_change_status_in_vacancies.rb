class ChangeStatusInVacancies < ActiveRecord::Migration[5.2]
  def change
    change_column :vacancies, :status, :integer, default: 0
  end
end
