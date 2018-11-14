require 'rails_helper'

RSpec.describe 'Admin employees API', type: :request do
  let(:password) { "123123" }
  let!(:admin_user)  { create(:user, password: password, is_admin: true) }
  let(:not_admin_user) { create(:user, password: password) }

  let!(:user)  { create(:user, password: password) }
  let!(:employee) { create(:employee, user_id: user.id, status: "added") }
  let(:employee_id) { employee.user_id }

  let!(:user2)  { create(:user, password: password) }
  let!(:employee2) { create(:employee, user_id: user2.id, status: "approved") }
  let(:employee_id2) { employee2.user_id }

  let!(:user3)  { create(:user, password: password) }
  let!(:employee3) { create(:employee, user_id: user3.id, status: "denied") }
  let(:employee_id3) { employee3.user_id }

  # Test suite for GET /admin_employees
  describe 'GET /admin_employees' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_employees", headers: { 'Authorization': token }
      end

      it "return all employees" do
        expect(json).not_to be_empty
        expect(json.size).to eq(3)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search status added' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_employees", params: { status: "added" }, headers: { 'Authorization': token }
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

        get "/admin_employees", params: { status: "approved" }, headers: { 'Authorization': token }
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

        get "/admin_employees", params: { status: "denied" }, headers: { 'Authorization': token }
      end

      it "returns employee" do
        expect(json).not_to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_employees", params: { limit: 2 }, headers: { 'Authorization': token }
      end

      it "returns 5 items" do
        expect(json).not_to be_empty
        expect(json.size).to eq(2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_employees", params: { offset: 1 }, headers: { 'Authorization': token }
      end

      it "returns items" do
        expect(json).not_to be_empty
        expect(json.size).to eq(2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        get "/admin_employees", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /admin_employees/1/approve
  describe 'POST /admin_employees/:id/approve' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_employees/#{employee_id}/approve", headers: { 'Authorization': token }
      end

      it 'returns changes the status' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(employee_id)
        expect(json['status']).to eq("approved")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:employee_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_employees/#{employee_id}/approve", headers: { 'Authorization': token }
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

        post "/admin_employees/#{employee_id}/approve", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /admin_employees/1/deny
  describe 'POST /admin_employees/:id/deny' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_employees/#{employee_id}/deny", headers: { 'Authorization': token }
      end

      it 'returns changes the status' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(employee_id)
        expect(json['status']).to eq("denied")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:employee_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_employees/#{employee_id}/deny", headers: { 'Authorization': token }
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

        post "/admin_employees/#{employee_id}/deny", headers: { 'Authorization': token }
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
