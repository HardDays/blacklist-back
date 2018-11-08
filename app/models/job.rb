class Job < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :period

  belongs_to :employee

  def as_json(options={})
    res = super
    res[:employee_id] = employee.user_id

    if options[:only]
      return super
    end

    res
  end
end
