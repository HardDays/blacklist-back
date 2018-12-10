class Subscription < ApplicationRecord
  validates_uniqueness_of :user_id

  belongs_to :user
  has_many :payments, dependent: :destroy
end
