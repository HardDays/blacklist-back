require 'rails_helper'

RSpec.describe VacancyResponse, type: :model do
  it { should validate_presence_of(:employee_id) }
  it { should validate_presence_of(:vacancy_id) }

  it { should belong_to(:vacancy) }
  it "should be deleted when vacancy destroyed" do
    user1 = create(:user)
    user2 = create(:user)
    company = create(:company, user_id: user1.id)
    employee = create(:employee, user_id: user2.id)
    vacancy = create(:vacancy, company_id: company.id)
    vacancy_response = create(:vacancy_response, vacancy_id: vacancy.id, employee_id: employee.id)

    expect { vacancy.destroy }.to change { VacancyResponse.count }.by(-1)
  end

  it { should belong_to(:employee)}
  it "should be deleted when employee destroyed" do
    user1 = create(:user)
    user2 = create(:user)
    company = create(:company, user_id: user1.id)
    employee = create(:employee, user_id: user2.id)
    vacancy = create(:vacancy, company_id: company.id)
    vacancy_response = create(:vacancy_response, vacancy_id: vacancy.id, employee_id: employee.id)

    expect { employee.destroy }.to change { VacancyResponse.count }.by(-1)
  end
end
