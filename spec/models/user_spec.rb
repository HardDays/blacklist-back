require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }

  context "user confirmed" do
    subject { User.new(confirmed_at: DateTime.now) }
    it { should validate_presence_of(:password) }
  end

  it { should have_many(:tokens) }
  it { should belong_to(:image) }
  it "should not be deleted when image destroyed" do
    user = create(:user)
    image = create(:image)

    user.image = image
    user.save!
    expect { image.destroy }.to change { User.count }.by(0)
  end
end