require 'rails_helper'

RSpec.describe 'Admin ban list API', type: :request do
  let(:password) { "123123" }
  let!(:admin_user)  { create(:user, password: password, is_admin: true) }
  let(:not_admin_user) { create(:user, password: password) }

  let!(:ban_list) { create_list(:ban_list, 7) }
  let(:item) { ban_list.first }
  let(:item_id) { item.id }
  let!(:item1) { create(:ban_list, status: "approved") }
  let!(:item2) { create(:ban_list, status: "denied") }
  let!(:item3) { create(:ban_list, status: "added") }

  # Test suite for GET /admin_black_list
  describe 'GET /admin_black_list' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_black_list", headers: { 'Authorization': token }
      end

      it "return all in black list" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(10)
        expect(json['items'].size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search status added' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_black_list", params: { status: "added" }, headers: { 'Authorization': token }
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

        get "/admin_black_list", params: { status: "approved" }, headers: { 'Authorization': token }
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

        get "/admin_black_list", params: { status: "denied" }, headers: { 'Authorization': token }
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

        get "/admin_black_list", params: { limit: 5 }, headers: { 'Authorization': token }
      end

      it "returns 5 items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(10)
        expect(json['items'].size).to eq(5)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        get "/admin_black_list", params: { offset: 2 }, headers: { 'Authorization': token }
      end

      it "returns items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(10)
        expect(json['items'].size).to eq(8)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        get "/admin_black_list", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /admin_black_list/1/approve
  describe 'POST /admin_black_list/:id/approve' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_black_list/#{item_id}/approve", headers: { 'Authorization': token }
      end

      it 'returns changes the status' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(item_id)
        expect(json['status']).to eq("approved")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:item_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_black_list/#{item_id}/approve", headers: { 'Authorization': token }
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

        post "/admin_black_list/#{item_id}/approve", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /admin_black_list/1/deny
  describe 'POST /admin_black_list/:id/deny' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_black_list/#{item_id}/deny", headers: { 'Authorization': token }
      end

      it 'returns changes the status' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(item_id)
        expect(json['status']).to eq("denied")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:item_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/admin_black_list/#{item_id}/deny", headers: { 'Authorization': token }
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

        post "/admin_black_list/#{item_id}/deny", headers: { 'Authorization': token }
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
