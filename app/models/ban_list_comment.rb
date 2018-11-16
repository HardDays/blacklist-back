class BanListComment < ApplicationRecord
  validates_presence_of :text

  belongs_to :user
  belongs_to :ban_list

  enum comment_type: [:like, :dislike]
end
