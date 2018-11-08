require 'rails_helper'

RSpec.describe Job, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:period) }

  it { should belong_to(:employee) }
  it "should be deleted when employee destroyed" do
    user = create(:user)
    employee = create(:employee, user_id: user.id)
    job = create(:job, employee_id: employee.id)

    expect { employee.destroy }.to change { Job.count }.by(-1)
  end
end
