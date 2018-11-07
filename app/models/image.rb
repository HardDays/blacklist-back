class Image < ApplicationRecord
  validates_presence_of :base64

  has_one :user
end
