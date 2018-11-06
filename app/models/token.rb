class Token < ApplicationRecord
  validates_presence_of :info

  belongs_to :user

  before_create do
    self.token = SecureRandom.hex + SecureRandom.hex
  end
end
