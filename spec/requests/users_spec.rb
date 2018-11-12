require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  # initialize test data
  let!(:users) { create_list(:user, 10) }
  let(:user_id) { users.first.id }
  let(:user) { users.first }

  let(:auth_user) { create(:user, password: "123123") }

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

  # Test suite for GET /users/my
  describe 'GET /users/my' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: auth_user.email, password: "123123"}
        token = json['token']

        get "/users/my", headers: { 'Authorization': token }
      end

      it 'returns the user' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(auth_user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the user not authorized' do
      before { get "/users/my" }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /users/verify_code
  describe 'POST /users/verify_code' do
    # valid payload
    let(:valid_attributes) { { code: user.confirmation_token, email: user.email } }

    context 'when the request is valid' do
      before { post '/users/verify_code', params: valid_attributes }

      it 'returns a user' do
        expect(json['email']).to eq(user.email)
        expect(json['id']).to eq(user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the code is invalid' do
      before { post '/users/verify_code', params: { code: 0, email: user.email } }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("")
      end
    end

    context 'when the email is invalid' do
      before { get '/users/verify_code', params: { code: user.confirmation_token, email: "aaa.aaa" } }

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
    let(:valid_attributes) { { password: "123123", password_confirmation: "123123" } }

    context 'when the request is valid' do
      before do
        post "/users/verify_code", params: { code: user.confirmation_token, email: user.email }
        token = json['token']

        patch "/users/#{user_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'sets user password' do
        expect(json['id']).to eq(user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request without password' do
      before do
        post "/users/verify_code", params: { code: user.confirmation_token, email: user.email }
        token = json['token']

        patch "/users/#{user_id}", params: {}, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"password\":[\"can't be blank\"]}")
      end
    end

    context 'when the request password mistmatch' do
      before do
        post "/users/verify_code", params: { code: user.confirmation_token, email: user.email }
        token = json['token']

        patch "/users/#{user_id}", params: { password: "123123", password_confirmation: "1231234"}, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"password_confirmation\":[\"NOT_MATCHED\"]}")
      end
    end

    context 'when the request without authorization' do
      before { patch "/users/#{user_id}", params: { password: "123123", password_confirmation: "123123"} }

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