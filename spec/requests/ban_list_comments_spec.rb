require 'rails_helper'

RSpec.describe "BanListComments API", type: :request do
  let(:password) { "123123" }
  let(:user)  { create(:user, password: password, is_payed: true) }
  let!(:item) { create(:ban_list, status: "approved") }
  let(:item_id) { item.id }

  let!(:comment) { create(:ban_list_comment, user_id: user.id, ban_list_id: item.id)}
  let!(:comment2) { create(:ban_list_comment, user_id: user.id, ban_list_id: item.id)}
  let!(:comment3) { create(:ban_list_comment, user_id: user.id, ban_list_id: item.id)}

  let(:like_valid_params) { { comment_type: "like", text: "Text" } }
  let(:dislike_valid_params) { { comment_type: "like", text: "Text" } }
  let(:without_text) { { comment_type: "like" } }
  let(:without_comment_type) { { text: "Text" } }

  # Test suite for GET /black_list/:black_list_id/black_list_comments
  describe 'GET /black_list/:black_list_id/black_list_comments' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list/#{item_id}/black_list_comments", headers: { 'Authorization': token }
      end

      it "return only approved" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list/#{item_id}/black_list_comments", params: { limit: 2 }, headers: { 'Authorization': token}
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

        get "/black_list/#{item_id}/black_list_comments", params: { offset: 1 }, headers: { 'Authorization': token}
      end

      it "returns response" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
        expect(json['items'][0]['id']).to eq(comment2.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when ban item denied' do
      before do
        item.status = "denied"
        item.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list/#{item_id}/black_list_comments", headers: { 'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when user not payed' do
      before do
        user.is_payed = false
        user.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/black_list/#{item_id}/black_list_comments", headers: { 'Authorization': token}
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
        get "/black_list/#{item_id}/black_list_comments"
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /black_list/:black_list_id/black_list_comments
  describe 'POST /black_list/:black_list_id/black_list_comments' do
    context 'when valid like comment request' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list/#{item_id}/black_list_comments", params: like_valid_params, headers: { 'Authorization': token }
      end

      it 'creates a response' do
        expect(json['user_id']).to eq(user.id)
        expect(json['black_list_id']).to eq(item.id)
        expect(json['text']).to eq('Text')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when valid dislike comment params' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list/#{item_id}/black_list_comments", params: dislike_valid_params, headers: { 'Authorization': token }
      end

      it 'creates a response' do
        expect(json['user_id']).to eq(user.id)
        expect(json['black_list_id']).to eq(item.id)
        expect(json['text']).to eq('Text')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when ban item denied' do
      before do
        item.status = "denied"
        item.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list/#{item_id}/black_list_comments", params: dislike_valid_params, headers: { 'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/black_list/#{item_id}/black_list_comments"
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
        user.is_payed = false
        user.save

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list/#{item_id}/black_list_comments", params: like_valid_params, headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'without text' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list/#{item_id}/black_list_comments", params: without_text, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"text\":[\"can't be blank\"]}")
      end
    end

    context 'without comment type' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/black_list/#{item_id}/black_list_comments", params: without_comment_type, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"comment_type\":[\"can't be blank\"]}")
      end
    end
  end
end
