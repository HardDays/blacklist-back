class Employee < ApplicationRecord
  validates_presence_of :first_name
  validates_presence_of :second_name
  validates_presence_of :last_name

  belongs_to :user
  has_many :jobs, dependent: :destroy
  has_many :vacancy_responses, dependent: :destroy
  has_many :employee_offers, dependent: :destroy

  enum status: [:added, :approved, :denied]
  enum gender: [:m, :f]

  def as_json(options={})
    res = super
    res.delete('user_id')
    res[:id] = user_id

    if options[:only]
      return res
    end

    if options[:short]
      attrs = {}
      attrs[:id] = user_id
      attrs[:first_name] = first_name
      attrs[:second_name] = second_name
      attrs[:last_name] = last_name
      attrs[:position] = position
      attrs[:experience] = experience
      attrs[:status] = status

      return attrs
    end

    res[:jobs] = jobs

    res
  end
end
