require 'rails_helper'

RSpec.describe "News", type: :request do
  let(:password) { "123123" }
  let!(:admin_user)  { create(:user, password: password, is_admin: true) }
  let(:not_admin_user) { create(:user, password: password) }

  let!(:news) { create_list(:news, 10) }
  let!(:new_item) { news[0] }
  let!(:new_id) { new_item.id }
  let(:valid_attributes) { { text: "address" } }
  let(:invalid_attributes) { { } }

  # Test suite for GET /news
  describe 'GET /news' do
    context 'when simply get' do
      before do
        get "/news"
      end

      it "return all approved news" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(10)
        expect(json['items'].size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        get "/news", params: { limit: 8 }
      end

      it "returns 8 news" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(10)
        expect(json['items'].size).to eq(8)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        get "/news", params: { offset: 5 }
      end

      it "returns news" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(10)
        expect(json['items'].size).to eq(5)
        expect(json['items'][0]['id']).to eq(news[5].id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end


  # Test suite for GET /news/:id
  describe 'GET /news/:id' do
    context 'when the record exists' do
      before do
        get "/news/#{new_id}"
      end

      it 'returns the employee' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(new_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:new_id) { 0 }

      before do
        get "/news/#{new_id}"
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end


  # Test suite for POST /news
  describe 'POST /news' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/news", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns changes the status' do
        expect(json).not_to be_empty
        expect(json['text']).to eq("address")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        post "/news", params: invalid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
            .to match("{\"text\":[\"can't be blank\"]}")
      end
    end

    context 'when the user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        post "/news", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the request without authorization' do
      before { post "/news", params: valid_attributes }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for PATCH /news/:id
  describe 'PATCH /news/:id' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        patch "/news/#{new_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'sets fields' do
        expect(json['text']).to eq("address")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when news doesn\'t exists' do
      let(:new_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        patch "/news/#{new_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns empty response' do
        expect(response.body).to match("")
      end
    end

    context 'when the request without authorization' do
      before { patch "/news/#{new_id}", params: valid_attributes }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the user not admin' do
      before do
        post "/auth/login", params: { email: not_admin_user.email, password: password }
        token = json['token']

        patch "/news/#{new_id}", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for DELETE /news/:id
  describe 'DELETE /news/:id' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        delete "/news/#{new_id}", headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:new_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        delete "/news/#{new_id}", headers: { 'Authorization': token }
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

        delete "/news/#{new_id}", headers: { 'Authorization': token }
      end

      it 'returns nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the request without authorization' do
      before { delete "/news/#{new_id}", params: valid_attributes }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end
end
