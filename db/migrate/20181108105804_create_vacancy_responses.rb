class CreateVacancyResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :vacancy_responses do |t|
      t.integer :vacancy_id
      t.integer :employee_id

      t.timestamps
    end
  end
end
