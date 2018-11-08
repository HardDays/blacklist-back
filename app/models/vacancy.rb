class Vacancy < ApplicationRecord
  validates_presence_of :description
  validates_presence_of :position

  belongs_to :company
end
