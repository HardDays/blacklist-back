require 'rails_helper'

RSpec.describe 'Admin users API', type: :request do
  let(:password) { "123123" }
  let!(:admin_user)  { create(:user, password: password, is_admin: true) }
  let(:not_admin_user) { create(:user, password: password) }

  let!(:users) { create_list(:user, 10) }
  let(:user) { users.first }
  let(:user_id) { user.id }

  # Test suite for GET /admin_users
  describe 'GET /admin_users' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_users", headers: { 'Authorization': token }
      end

      it "return all users" do
        expect(json).not_to be_empty
        expect(json.size).to eq(11)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_users", params: { limit: 5 }, headers: { 'Authorization': token }
      end

      it "returns 5 items" do
        expect(json).not_to be_empty
        expect(json.size).to eq(5)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_users", params: { offset: 2 }, headers: { 'Authorization': token }
      end

      it "returns items" do
        expect(json).not_to be_empty
        expect(json.size).to eq(9)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        get "/admin_users", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /admin_users/1/block
  describe 'POST /admin_black_list/:id/approve' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_users/#{user_id}/block", headers: { 'Authorization': token }
      end

      it 'returns changes the status' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user_id)
        expect(json['is_blocked']).to eq(true)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:user_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_users/#{user_id}/block", headers: { 'Authorization': token }
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

        post "/admin_users/#{user_id}/block", headers: { 'Authorization': token }
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
