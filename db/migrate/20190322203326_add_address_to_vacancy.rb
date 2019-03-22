class AddAddressToVacancy < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :address, :string
  end
end
