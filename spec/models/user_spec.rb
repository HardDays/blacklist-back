require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }

  context "user confirmed" do
    subject { User.new(confirmed_at: DateTime.now) }
    it { should validate_presence_of(:password) }
  end
end