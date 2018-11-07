class Company < ApplicationRecord
  validates_presence_of :name

  belongs_to :user
  has_many :vacancies, dependent: :destroy
end
