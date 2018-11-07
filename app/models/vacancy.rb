class Vacancy < ApplicationRecord
  validates_presence_of :description

  belongs_to :company
end
