require 'rails_helper'

RSpec.describe Token, type: :model do
  it { should validate_presence_of(:info) }
  it { should belong_to(:user) }
  it "should be deleted when user destroyed" do
    user = create(:user)
    token = create(:token, user_id: user.id)

    expect { user.destroy }.to change { Token.count }.by(-1)
  end
end
