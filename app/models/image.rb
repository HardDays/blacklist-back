class Image < ApplicationRecord
  validates_presence_of :base64

  belongs_to :user
end
