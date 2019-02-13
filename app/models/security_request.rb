class SecurityRequest < ApplicationRecord
  validates_presence_of :base64
  validates_presence_of :user_id

  belongs_to :user

  def as_json(options={})
    res = super
    res[:email] = user.email

    res
  end
end
