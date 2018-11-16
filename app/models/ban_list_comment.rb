class BanListComment < ApplicationRecord
  validates_presence_of :text
  validates_presence_of :comment_type

  belongs_to :user
  belongs_to :ban_list

  enum comment_type: [:like, :dislike]

  def as_json(options={})
    res = super

    res.delete('ban_list_id')
    res[:black_list_id] = ban_list_id
    res[:user] = user

    res
  end
end
