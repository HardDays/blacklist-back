require "rails_helper"

RSpec.describe 'Admin ban list comments API', type: :request do
  let(:password) { "123123" }
  let!(:admin_user)  { create(:user, password: password, is_admin: true) }
  let(:not_admin_user) { create(:user, password: password) }

  let!(:item) { create(:ban_list) }
  let(:item_id) { item.id }

  let(:comment) { create(:ban_list_comment, user_id: not_admin_user.id, ban_list_id: item.id) }
  let(:comment_id) { comment.id }

  # Test suite for DELETE /admin_black_list_comments/:id
  describe 'DELETE /admin_black_list_comments/:id' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        delete "/admin_black_list_comments/#{comment_id}", headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:comment_id) { 0 }

      before do
        post "/auth/login", params: { email: admin_user.email, password: password }
        token = json['token']

        delete "/admin_black_list_comments/#{comment_id}", headers: { 'Authorization': token }
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

        delete "/admin_black_list_comments/#{comment_id}", headers: { 'Authorization': token }
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
