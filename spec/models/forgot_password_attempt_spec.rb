require 'rails_helper'

RSpec.describe ForgotPasswordAttempt, type: :model do
  it { belong_to(:user) }
  it "should be deleted when user destroyed" do
    user = create(:user)
    password_attempt = create(:forgot_password_attempt, user_id: user.id)

    expect { user.destroy }.to change { ForgotPasswordAttempt.count }.by(-1)
  end
end
