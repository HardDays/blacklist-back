require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  # initialize test data
  let(:user) { create(:user, password: "123123") }


  # Test suite for POST /auth/login
  describe 'POST /auth/login' do
    # valid payload
    let(:valid_attributes) { { email: user.email, password: "123123" } }

    context 'when the request is valid' do
      before { post '/auth/login', params: valid_attributes }

      it 'logins a user' do
        expect(json['token']).to be_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the password invalid' do
      before { post '/auth/login', params: { email: user.email, password: "123" } }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the email invalid' do
      before { post '/auth/login', params: { email: "aa.con", password: "123123" } }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /auth/logout
  describe 'POST /auth/logout' do
    let(:valid_attributes) { { email: user.email, password: "123123" } }

    context 'when the request is valid' do
      before do
        post "/users/verify_code", params: { code: user.confirmation_token, email: user.email }
        token = json['token']

        post "/auth/logout", headers: { 'Authorization': token }
      end

      it 'sends nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid' do
      before do
        post "/auth/logout"
      end

      it 'sends nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end
  end
end