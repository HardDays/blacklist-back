require 'rails_helper'

RSpec.describe EmployeeOffer, type: :model do
  it { should validate_presence_of(:position) }

  it { should belong_to(:employee) }
  it "should be deleted when employee destroyed" do
    user = create(:user)
    employee = create(:employee, user_id: user.id)
    user2 = create(:user)
    company = create(:company, user_id: user2.id)
    employee_offer = create(:employee_offer, employee_id: employee.id, company_id: company.id)

    expect { employee.destroy }.to change { EmployeeOffer.count }.by(-1)
  end

  it { should belong_to(:company) }
  it "should be deleted when employee destroyed" do
    user = create(:user)
    employee = create(:employee, user_id: user.id)
    user2 = create(:user)
    company = create(:company, user_id: user2.id)
    employee_offer = create(:employee_offer, employee_id: employee.id, company_id: company.id)

    expect { company.destroy }.to change { EmployeeOffer.count }.by(-1)
  end
end
