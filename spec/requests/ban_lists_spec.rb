require 'rails_helper'

RSpec.describe "BanLists API", type: :request do
  let(:password) { "123123" }
  let(:user)  { create(:user, password: password) }
  let!(:payment) { create(:payment, user_id: user.id, expires_at: DateTime.now + 1.day, payment_type: 'standard', status: 'ok')}
  let!(:item) { create(:ban_list, status: "approved") }
  let!(:item2) { create(:ban_list, status: "approved") }
  let!(:item3) { create(:ban_list, status: "approved") }
  let!(:item4) { create(:ban_list, status: "denied") }
  let!(:item5) { create(:ban_list, status: "added") }
  let(:item_id) { item.id }

  let(:employee_valid_params) { { item_type: "employee", name: "Name", description: "Description", addresses: "Addresses" } }
  let(:company_valid_params) { { item_type: "company", name: "Name", description: "Description", addresses: "Addresses" } }
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

      it "return only approved" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
        expect(json['items'][0]['id']).to eq(item_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list", params: { limit: 2 }, headers: { 'Authorization': token}
      end

      it "returns 2 entities" do
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
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list", params: { offset: 2 }, headers: { 'Authorization': token}
      end

      it "returns response" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(1)
        expect(json['items'][0]['id']).to eq(item3.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user payed economy' do
      before do
        payment.payment_type = 'economy'
        payment.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list", headers: { 'Authorization': token}
      end

      it "return only approved" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
        expect(json['items'][0]['id']).to eq(item_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not payed standard' do
      before do
        payment.expires_at = DateTime.now - 1.day
        payment.save

        post "/auth/login", params: { email: user.email, password: password}
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

    context 'when user not payed economy' do
      before do
        payment.payment_type = 'economy'
        payment.expires_at = DateTime.now - 1.day
        payment.save

        post "/auth/login", params: { email: user.email, password: password}
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

  # Test suite for GET /black_list/:id
  describe 'GET /black_list/:id' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/black_list/#{item_id}", headers: { 'Authorization': token }
      end

      it 'returns the item' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(item_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the user payed economy' do
      before do
        payment.payment_type = 'economy'
        payment.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list/#{item_id}", headers: { 'Authorization': token }
      end

      it 'returns the item' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(item_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the user not payed standard' do
      before do
        payment.expires_at = DateTime.now - 1.day
        payment.save

        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/black_list/#{item_id}", headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the user not payed economy' do
      before do
        payment.payment_type = 'economy'
        payment.expires_at = DateTime.now - 1.day
        payment.save

        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/black_list/#{item_id}", headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the record does not exist' do
      let(:item_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/black_list/#{item_id}", headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when the record not approved' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/black_list/#{item4.id}", headers: { 'Authorization': token }
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
        get "/black_list/#{item_id}"
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /black_list
  describe 'POST /black_list' do
    context 'when valid employee request' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list", params: employee_valid_params, headers: { 'Authorization': token }
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

    context 'when valid company params' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list", params: company_valid_params, headers: { 'Authorization': token }
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

    context 'when the user payed economy' do
      before do
        payment.payment_type = 'economy'
        payment.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list", params: employee_valid_params, headers: { 'Authorization': token }
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

    context 'when the user not payed standard' do
      before do
        payment.expires_at = DateTime.now - 1.day
        payment.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list", params: employee_valid_params, headers: { 'Authorization': token }
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

    context 'when the user not payed economy' do
      before do
        payment.payment_type = 'economy'
        payment.expires_at = DateTime.now - 1.day
        payment.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list", params: employee_valid_params, headers: { 'Authorization': token }
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
