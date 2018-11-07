require 'rails_helper'

RSpec.describe Image, type: :model do
  it { should validate_presence_of(:base64) }

  it { should belong_to(:user) }
  it "should be deleted when delete user" do
    user = create(:user)
    image = create(:image, user_id: user.id)

    user.image = image
    user.save!
    expect { user.destroy }.to change { Image.count }.by(-1)
  end
end
