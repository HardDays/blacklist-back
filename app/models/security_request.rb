class SecurityRequest < ApplicationRecord
  validates_presence_of :base64

  belongs_to :user

  def as_json(options={})
    res = super
    res[:email] = user.email

    res
  end
end
