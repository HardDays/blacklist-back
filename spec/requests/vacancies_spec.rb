require 'rails_helper'

RSpec.describe 'Vacancies API', type: :request do
  let(:date_time) { Time.now }
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, is_payed: true) }
  let!(:company) { create(:company, user_id: user.id) }
  let(:company_id) { company.user_id }
  let!(:vacancy) { create(:vacancy, company_id: company.id, status: "approved") }
  let(:vacancy_id) { vacancy.id }

  let!(:user2)  { create(:user, password: password) }
  let!(:company2) { create(:company, user_id: user2.id) }
  let(:company_id2) { company2.user_id }

  let!(:vacancy2) { create(:vacancy, company_id: company.id, status: "approved") }
  let(:vacancy_id2) { vacancy2.id }

  let!(:vacancy3) { create(:vacancy, company_id: company.id, status: "approved") }
  let!(:vacancy4) { create(:vacancy, company_id: company2.id, status: "denied") }
  let!(:vacancy5) { create(:vacancy, company_id: company.id, status: "added") }

  let(:valid_attributes) { {  company_id: company_id, position: "Position", min_experience: 1,
                              salary: 120, description: "Description" } }
  let(:without_position) { { company_id: company_id, min_experience: 1,
                             salary: 120, description: "Description" } }
  let(:without_description) { { company_id: company_id, position: "Position", min_experience: 1,
                             salary: 120 } }

  # Test suite for GET /vacancies
  describe 'GET /vacancies' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies", headers: { 'Authorization': token }
      end

      it "return all vacancies" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search position' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies", params: { text: vacancy.position}, headers: { 'Authorization': token }
      end

      it "returns employee" do
        expect(json['count']).to eq(3)
        expect(json['items'][0]['id']).to eq(vacancy_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies", params: { limit: 1 }, headers: { 'Authorization': token }
      end

      it "returns 5 employee" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies", params: { offset: 1 }, headers: { 'Authorization': token }
      end

      it "returns employees" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
        expect(json['items'][0]['id']).to eq(vacancy_id2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not payed' do
      before do
        user.is_payed = false
        user.save

        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before do
        get "/vacancies"
      end

      it "returns empty message" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end


  # Test suite for GET /vacancies/:id
  describe 'GET /vacancies/:id' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies/#{vacancy_id}", headers: { 'Authorization': token }
      end

      it 'returns the vacancy' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(vacancy_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record not approved' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies/#{vacancy4.id}", headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when my record not approved' do
      before do
        vacancy.status = "added"
        vacancy.save

        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies/#{vacancy_id}", headers: { 'Authorization': token }
      end

      it 'i still have access' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(vacancy_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not payed' do
      before do
        user2.is_payed = false
        user2.save

        post "/auth/login", params: { email: user2.email, password: password }
        token = json['token']

        get "/vacancies/#{vacancy_id}", headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when i did not payed' do
      before do
        user.is_payed = false
        user.save

        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies/#{vacancy_id}", headers: { 'Authorization': token }
      end

      it 'i still have access' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(vacancy_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:vacancy_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/vacancies/#{vacancy_id}", headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when not authorized' do
      before do
        get "/vacancies/#{vacancy_id}"
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /companies/:id/vacancies/
  describe 'POST /vacancies' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/companies/#{company_id}/vacancies", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates an vacancy' do
        expect(json['position']).to eq('Position')
        expect(json['description']).to eq('Description')
        expect(json['salary']).to eq(120)
        expect(json['min_experience']).to eq(1)
        expect(json['company_id']).to eq(user.id)
        expect(company.vacancies).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request without position' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/companies/#{company_id}/vacancies", params: without_position, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"position\":[\"can't be blank\"]}")
      end
    end

    context 'when the request without description' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/companies/#{company_id}/vacancies", params: without_description, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"description\":[\"can't be blank\"]}")
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/companies/#{company_id}/vacancies", params: valid_attributes
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for PATCH /companies/#{company_id}/vacancies/:id
  describe 'PATCH /companies/:company_id/vacancies/:id' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/companies/#{company_id}/vacancies/#{vacancy_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'sets fields' do
        expect(json['position']).to eq('Position')
        expect(json['description']).to eq('Description')
        expect(json['salary']).to eq(120)
        expect(json['min_experience']).to eq(1)
        expect(json['company_id']).to eq(user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when employee doesn\'t exists' do
      let(:vacancy_id) { 0 }

      before do
        post "/users/verify_code", params: { code: user.confirmation_token, email: user.email }
        token = json['token']

        patch "/companies/#{company_id}/vacancies/#{vacancy_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns empty response' do
        expect(response.body).to match("")
      end
    end

    context 'when the request without authorization' do
      before { patch "/companies/#{company_id}/vacancies/#{vacancy_id}", params: valid_attributes }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end
end
