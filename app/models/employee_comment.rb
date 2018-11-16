class EmployeeComment < ApplicationRecord
  validates_presence_of :text
  validates_presence_of :comment_type

  belongs_to :user

  enum comment_type: [:like, :dislike]

  def as_json(options={})
    res = super

    res[:user] = user

    res
  end
end
