class SecurityFile < ApplicationRecord
  validates_presence_of :base64
end
