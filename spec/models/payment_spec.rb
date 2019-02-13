require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { should validate_presence_of(:payment_type) }
  it { should validate_presence_of(:user_id) }

  it { should belong_to(:user) }
  it "should be deleted when delete user" do
    user = create(:user)
    payment = create(:payment, user_id: user.id, payment_type: 'standard')

    expect { user.destroy }.to change { Payment.count }.by(-1)
  end
end
