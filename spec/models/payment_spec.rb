require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { should belong_to(:subscription) }
  it "should be deleted when delete user" do
    user = create(:user)
    subscription = create(:subscription, user_id: user.id)
    payment = create(:payment, subscription_id: subscription.id)

    expect { subscription.destroy }.to change { Payment.count }.by(-1)
  end
end
