class BanList < ApplicationRecord
  scope :approved, -> { where(status: Employee.statuses["approved"]) }

  validates_presence_of :name
  validates_presence_of :description

  enum status: [:added, :approved, :denied]
  enum item_type: [:employee, :company]

  has_many :ban_list_comments, dependent: :destroy
end
