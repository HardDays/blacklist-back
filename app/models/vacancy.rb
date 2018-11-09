class Vacancy < ApplicationRecord
  validates_presence_of :description
  validates_presence_of :position

  belongs_to :company
  has_many :vacancy_responses, dependent: :destroy

  def as_json(options={})
    res = super
    res[:company_id] = company.user_id
    res[:company_name] = company.name

    if options[:only]
      return res
    end

    if options[:short]
      res.delete('company_id')
      res.delete('description')
      res.delete('min_experience')

      return res
    end

    res
  end
end
