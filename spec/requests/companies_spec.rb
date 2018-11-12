require 'rails_helper'

RSpec.describe 'Company API', type: :request do
  let(:password) { "123123" }
  let(:user)  { create(:user, password: password) }
  let(:company) { create(:company, user_id: user.id) }
  let(:company_id) { company.user_id }

  let(:user2)  { create(:user, password: password) }
  let(:company2) { create(:company, user_id: user2.id) }
  let(:company_id2) { company2.user_id }

  # valid payload
  let(:valid_attributes) { { id: user.id, name: 'name', description: "description", contacts: "contacts", address: "address" } }
  let(:invalid_attributes) { { id: user.id, description: "description", contacts: "contacts", address: "address" } }

  # Test suite for GET /companies/:id
  describe 'GET /companies/:id' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/companies/#{company_id}", headers: { 'Authorization': token }
      end

      it 'returns the company' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(company_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:company_id) { 100 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/companies/#{company_id}", headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when it is not my company' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/companies/#{company_id2}", headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when not authorized' do
      before { get "/companies/#{company_id}" }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /companies/
  describe 'POST /companies' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/companies", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates a company' do
        expect(json['name']).to eq('name')
        expect(json['description']).to eq('description')
        expect(json['contacts']).to eq('contacts')
        expect(json['address']).to eq('address')
        expect(json['id']).to eq(user.id)
        expect(user.company).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/companies", params: invalid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"name\":[\"can't be blank\"]}")
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/companies", params: valid_attributes
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for PATCH /companies/
  describe 'PATCH /companies' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/companies/#{company_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'sets fields' do
        expect(json['id']).to eq(user.id)
        expect(json['name']).to eq('name')
        expect(json['description']).to eq('description')
        expect(json['contacts']).to eq('contacts')
        expect(json['address']).to eq('address')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when company doesn\'t exists' do
      let(:company_id) { 100 }

      before do
        post "/users/verify_code", params: { code: user.confirmation_token, email: user.email }
        token = json['token']

        patch "/companies/#{company_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns empty response' do
        expect(response.body).to match("")
      end
    end

    context 'when the request without authorization' do
      before { patch "/companies/#{company_id}", params: valid_attributes }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

end
