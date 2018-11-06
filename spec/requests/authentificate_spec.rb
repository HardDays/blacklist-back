require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  # initialize test data
  let(:user) { create(:auth_user) }


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
      before { post '/users', params: { email: user.email, password: "123" } }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the email invalid' do
      before { post '/users', params: { email: "aa.con", password: "123123" } }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

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
      before { post '/users', params: { email: user.email, password: "123" } }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the email invalid' do
      before { post '/users', params: { email: "aa.con", password: "123123" } }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for DELETE /todos/:id
  # describe 'DELETE /todos/:id' do
  #   before { delete "/todos/#{todo_id}" }
  #
  #   it 'returns status code 204' do
  #     expect(response).to have_http_status(204)
  #   end
  # end
end