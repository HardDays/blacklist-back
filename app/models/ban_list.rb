class BanList < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :description

  enum status: [:added, :approved, :denied]
end
