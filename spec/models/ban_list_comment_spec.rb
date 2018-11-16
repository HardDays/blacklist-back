require 'rails_helper'

RSpec.describe BanListComment, type: :model do
  it { should validate_presence_of(:text)}
  it { should validate_presence_of(:comment_type)}

  it { should belong_to(:user)}
  it "should be deleted when delete user" do
    user = create(:user)
    ban_list = create(:ban_list)
    comment = create(:ban_list_comment, user_id: user.id, ban_list_id: ban_list.id)

    expect { user.destroy }.to change { BanListComment.count }.by(-1)
  end

  it { should belong_to(:ban_list)}
  it "should be deleted when delete banlist item" do
    user = create(:user)
    ban_list = create(:ban_list)
    comment = create(:ban_list_comment, user_id: user.id, ban_list_id: ban_list.id)

    expect { ban_list.destroy }.to change { BanListComment.count }.by(-1)
  end
end
