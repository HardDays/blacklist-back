class Employee < ApplicationRecord
  validates_presence_of :first_name
  validates_presence_of :second_name
  validates_presence_of :last_name

  belongs_to :user
  has_many :jobs, dependent: :destroy
  has_many :vacancy_responses, dependent: :destroy

  enum status: [:draft, :posted]
  enum gender: [:m, :f]
end
