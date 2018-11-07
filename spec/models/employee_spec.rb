require 'rails_helper'

RSpec.describe Employee, type: :model do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:second_name) }
  it { should validate_presence_of(:last_name) }

  it { should belong_to(:user) }
  it "should be deleted when delete user" do
    user = create(:user)
    employee = create(:employee, user_id: user.id)

    user.employee = employee
    user.save!
    expect { user.destroy }.to change { Employee.count }.by(-1)
  end
end
