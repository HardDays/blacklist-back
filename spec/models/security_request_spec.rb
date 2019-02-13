require 'rails_helper'

RSpec.describe SecurityRequest, type: :model do
  it { should validate_presence_of(:base64) }
  it { should validate_presence_of(:user_id) }

  it { should belong_to(:user) }
  it "should be deleted when delete user" do
    user = create(:user)
    security_request = create(:security_request, user_id: user.id)

    expect { user.destroy }.to change { SecurityRequest.count }.by(-1)
  end
end
