require 'rails_helper'

RSpec.describe "VacancyResponse APIs", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password) }
  let!(:company) { create(:company, user_id: user.id) }
  let(:company_id) { company.user_id }
  let!(:vacancy) { create(:vacancy, company_id: company.id) }
  let(:vacancy_id) { vacancy.id }

  let!(:user2)  { create(:user, password: password) }
  let!(:employee) { create(:employee, user_id: user2.id) }
  let(:employee_id) { employee.user_id }

  let!(:user3)  { create(:user, password: password) }
  let!(:employee2) { create(:employee, user_id: user3.id) }
  let(:employee_id2) { employee2.user_id }

  let!(:vacancy_response) { create(:vacancy_response, employee_id: employee.id, vacancy_id: vacancy.id) }
  let!(:vacancy_response2) { create(:vacancy_response, employee_id: employee2.id, vacancy_id: vacancy.id) }

  let!(:user3)  { create(:user, password: password) }
  let!(:company2) { create(:company, user_id: user3.id) }
  let(:company_id2) { company2.user_id }
  let!(:vacancy2) { create(:vacancy, company_id: company2.id) }
  let(:vacancy_id2) { vacancy2.id }


  # Test suite for GET /vacancies/:vacancy_id/vacancy_responses
  describe 'GET /vacancy_responses' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/vacancies/#{vacancy_id}/vacancy_responses", headers: { 'Authorization': token }
      end

      it "return all vacancy responses" do
        expect(json).not_to be_empty
        expect(json.size).to eq(2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/vacancies/#{vacancy_id}/vacancy_responses", params: { limit: 1 }, headers: { 'Authorization': token }
      end

      it "returns 1 response" do
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/vacancies/#{vacancy_id}/vacancy_responses", params: { offset: 1 }, headers: { 'Authorization': token }
      end

      it "returns response" do
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
        expect(json[0]['id']).to eq(vacancy_response2.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when vacancy does not exists' do
      let(:vacancy_id) { 100 }
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/vacancies/#{vacancy_id}/vacancy_responses", params: { offset: 1 }, headers: { 'Authorization': token }
      end

      it "returns response" do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when not authorized' do
      before do
        get "/vacancies/#{vacancy_id}/vacancy_responses"
      end

      it "returns response" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not my vacancy' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/vacancies/#{vacancy_id2}/vacancy_responses", headers: { 'Authorization': token }
      end

      it "returns response" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /vacancy/#{vacancy_id}/vacancy_responses/
  describe 'POST /vacancy_responses' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user2.email, password: password}
        token = json['token']

        post "/vacancies/#{vacancy_id}/vacancy_responses", headers: { 'Authorization': token }
      end

      it 'creates a response' do
        expect(vacancy.vacancy_responses).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/vacancies/#{vacancy_id}/vacancy_responses"
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not an employee' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/vacancies/#{vacancy_id}/vacancy_responses", headers: { 'Authorization': token }
      end

      it 'creates a response' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end
end
