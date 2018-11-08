class AddFieldsToVacancy < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :position, :string
    add_column :vacancies, :min_experience, :integer
    add_column :vacancies, :salary, :integer
  end
end
