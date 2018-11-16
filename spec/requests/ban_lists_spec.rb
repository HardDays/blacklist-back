require 'rails_helper'

RSpec.describe "BanLists API", type: :request do
  let(:password) { "123123" }
  let(:user)  { create(:user, password: password, is_payed: true) }
  let(:not_payed_user)  { create(:user, password: password) }
  let!(:ban_list)  { create_list(:ban_list, 10) }

  let(:valid_params) { { item_type: "employee", name: "Name", description: "Description", addresses: "Addresses" } }
  let(:without_name) { { item_type: "employee", description: "Description", addresses: "Addresses" } }
  let(:without_description) { { item_type: "employee", name: "Name", addresses: "Addresses" } }

  # Test suite for GET /ban_list
  describe 'GET /ban_list' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list", headers: { 'Authorization': token}
      end

      it "return all ban list" do
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list", params: { limit: 5 }, headers: { 'Authorization': token}
      end

      it "returns 5 entities" do
        expect(json).not_to be_empty
        expect(json.size).to eq(5)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list", params: { offset: 3 }, headers: { 'Authorization': token}
      end

      it "returns response" do
        expect(json).not_to be_empty
        expect(json.size).to eq(7)
        expect(json[0]['id']).to eq(ban_list[3].id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not payed' do
      before do
        post "/auth/login", params: { email: not_payed_user.email, password: password}
        token = json['token']

        get "/black_list", headers: { 'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before do
        get "/black_list"
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /black_list
  describe 'POST /black_list' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list", params: valid_params, headers: { 'Authorization': token }
      end

      it 'creates a response' do
        expect(json['name']).to eq('Name')
        expect(json['description']).to eq('Description')
        expect(json['addresses']).to eq('Addresses')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/black_list"
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when the user not payed' do
      before do
        post "/auth/login", params: { email: not_payed_user.email, password: password}
        token = json['token']

        post "/black_list", params: valid_params, headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'without name' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list", params: without_name, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"name\":[\"can't be blank\"]}")
      end
    end

    context 'without description' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list", params: without_description, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"description\":[\"can't be blank\"]}")
      end
    end
  end
end
