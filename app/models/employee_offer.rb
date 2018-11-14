class EmployeeOffer < ApplicationRecord
  validates_presence_of :position

  belongs_to :employee
  belongs_to :company

  def as_json(options={})
    res = super
    res[:employee_id] = employee.user_id
    res[:company_id] = company.user_id

    if options[:only]
      return super
    end

    res
  end
end
