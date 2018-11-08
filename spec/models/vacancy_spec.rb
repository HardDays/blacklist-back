require 'rails_helper'

RSpec.describe Vacancy, type: :model do
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:description) }

  it { should belong_to(:company) }
  it "should be deleted when employee destroyed" do
    user = create(:user)
    company = create(:company, user_id: user.id)
    vacancy = create(:vacancy, company_id: company.id)

    company.vacancies << vacancy
    company.save!
    expect { company.destroy }.to change { Vacancy.count }.by(-1)
  end
end
