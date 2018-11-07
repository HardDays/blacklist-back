require 'rails_helper'

RSpec.describe Company, type: :model do
  it { should validate_presence_of(:name) }

  it { should belong_to(:user) }
  it "should be deleted when delete user" do
    user = create(:user)
    company = create(:company, user_id: user.id)

    user.company = company
    user.save!
    expect { user.destroy }.to change { Company.count }.by(-1)
  end
end
