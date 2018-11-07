class Job < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :period

  belongs_to :employee
end
