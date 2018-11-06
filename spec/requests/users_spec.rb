require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  # initialize test data
  let!(:users) { create_list(:user, 10) }
  let(:user_id) { users.first.id }
  let(:user) { users.first }

  # Test suite for GET /users
  # describe 'GET /users' do
  #   # make HTTP get request before each example
  #   before { get '/users' }
  #
  #   it 'returns users' do
  #     # Note `json` is a custom helper to parse JSON responses
  #     expect(json).not_to be_empty
  #     expect(json.size).to eq(10)
  #   end
  #
  #   it 'returns status code 200' do
  #     expect(response).to have_http_status(200)
  #   end
  # end

  # Test suite for GET /users/:id
  describe 'GET /users/:id' do
    before { get "/users/#{user_id}" }

    context 'when the record exists' do
      it 'returns the user' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:user_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/get_by_code
  describe 'GET /users/get_by_code' do
    # valid payload
    let(:valid_attributes) { { code: user.confirmation_token } }

    context 'when the request is valid' do
      before { get '/users/get_by_code', params: valid_attributes }

      it 'returns a user' do
        expect(json['email']).to eq(user.email)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid' do
      before { get '/users/get_by_code', params: { code: 0 } }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("")
      end
    end
  end

  # Test suite for POST /users/
  describe 'POST /users' do
    # valid payload
    let(:valid_attributes) { { email: 'aaa@aaa.com' } }

    context 'when the request is valid' do
      before { post '/users', params: valid_attributes }

      it 'creates a user' do
        expect(json['email']).to eq('aaa@aaa.com')
        expect(user.confirmation_token).to be_kind_of(String)
        expect(user.confirmation_sent_at).not_to be_nil
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/users', params: { email: '' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"email\":[\"can't be blank\"]}")
      end
    end
  end

  # Test suite for PATCH /users/
  describe 'PATCH /users' do
    # valid payload
    let(:valid_attributes) { { email: user.email, code: user.confirmation_token,
                               password: "123123", password_confirmation: "123123" } }

    context 'when the request is valid' do
      before { patch "/users/#{user_id}", params: valid_attributes }

      it 'sets user password' do
        expect(json['token']).to be_kind_of(String)
        expect(user.password).to be_kind_of(String)
        expect(user.confirmed_at).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the code is invalid' do
      before { patch "/users/#{user_id}", params: { email: user.email, code: '0000',
                                        password: "123123", password_confirmation: "123123" } }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"errors\":[\"INVALID_CODE\"]}")
      end
    end

    context 'when the request without password' do
      before { patch "/users/#{user_id}", params: { email: user.email, code: user.confirmation_token} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"password\":[\"can't be blank\"]}")
      end
    end

    context 'when the request password mistmatch' do
      before { patch "/users/#{user_id}", params: { email: user.email, code: user.confirmation_token,
                                        password: "123123", password_confirmation: "1231234"} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"password_confirmation\":[\"NOT_MATCHED\"]}")
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