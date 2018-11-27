require 'rails_helper'

RSpec.describe 'Admin vacancies API', type: :request do
  let(:password) { "123123" }
  let!(:admin_user)  { create(:user, password: password, is_admin: true) }
  let(:not_admin_user) { create(:user, password: password) }

  let!(:user)  { create(:user, password: password) }
  let!(:company) { create(:company, user_id: user.id) }

  let!(:vacancy) { create(:vacancy, company_id: company.id, status: "approved") }
  let(:vacancy_id) { vacancy.id }

  let!(:vacancy2) { create(:vacancy, company_id: company.id, status: "denied") }
  let(:vacancy_id2) { vacancy2.id }

  let!(:vacancy3) { create(:vacancy, company_id: company.id, status: "added") }
  let(:vacancy_id3) { vacancy3.id }

  # Test suite for GET /admin_vacancies
  describe 'GET /admin_vacancies' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies", headers: { 'Authorization': token }
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

    context 'when search status added' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies", params: { status: "added" }, headers: { 'Authorization': token }
      end

      it "returns ban list" do
        expect(json).not_to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search approved' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies", params: { status: "approved" }, headers: { 'Authorization': token }
      end

      it "returns employee" do
        expect(json).not_to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search denied' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies", params: { status: "denied" }, headers: { 'Authorization': token }
      end

      it "returns employee" do
        expect(json).not_to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search position' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies", params: { text: vacancy.position}, headers: { 'Authorization': token }
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
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies", params: { limit: 2 }, headers: { 'Authorization': token }
      end

      it "returns 5 items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies", params: { offset: 1 }, headers: { 'Authorization': token }
      end

      it "returns items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end


  # Test suite for GET /admin_vacancies/:id
  describe 'GET /admin_vacancies/:id' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies/#{vacancy_id}", headers: { 'Authorization': token }
      end

      it "return vacancy" do
        expect(json).not_to be_empty
        expect(json['id']).to eq(vacancy_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        get "/admin_vacancies/#{vacancy_id}", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /admin_vacancies/1/approve
  describe 'POST /admin_vacancies/:id/approve' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_vacancies/#{vacancy_id}/approve", headers: { 'Authorization': token }
      end

      it 'returns changes the status' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(vacancy_id)
        expect(json['status']).to eq("approved")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:vacancy_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_vacancies/#{vacancy_id}/approve", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when the user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        post "/admin_vacancies/#{vacancy_id}/approve", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /admin_vacancies/1/deny
  describe 'POST /admin_vacancies/:id/deny' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_vacancies/#{vacancy_id}/deny", headers: { 'Authorization': token }
      end

      it 'returns changes the status' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(vacancy_id)
        expect(json['status']).to eq("denied")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:vacancy_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_vacancies/#{vacancy_id}/deny", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when the user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        post "/admin_vacancies/#{vacancy_id}/deny", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end
end
