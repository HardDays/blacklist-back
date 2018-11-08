class VacancyResponse < ApplicationRecord
  validates_presence_of :employee_id
  validates_presence_of :vacancy_id

  belongs_to :employee
  belongs_to :vacancy

  def as_json(options={})
    res = super

    res.delete("employee_id")
    res.delete("vacancy_id")

    res[:employee] = employee.as_json(short: true)

    res
  end
end
