class VacancyResponse < ApplicationRecord
  validates_presence_of :employee_id
  validates_presence_of :vacancy_id

  belongs_to :employee
  belongs_to :vacancy
end
