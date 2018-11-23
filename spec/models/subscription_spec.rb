require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { should have_many(:payments) }
  it { should belong_to(:user) }
  it "should be deleted when delete user" do
    user = create(:user)
    subscription = create(:subscription, user_id: user.id)

    expect { user.destroy }.to change { Subscription.count }.by(-1)
  end
end
