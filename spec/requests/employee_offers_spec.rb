require 'rails_helper'

RSpec.describe "EmployeeOffers", type: :request do
  let(:password) { "123123" }

  let!(:employee_user)  { create(:user, password: password) }
  let!(:employee_subscription) { create(:subscription, user_id: employee_user.id, last_payment_date: DateTime.now)}
  let!(:employee) { create(:employee, user_id: employee_user.id) }
  let(:employee_id) { employee.user_id }

  let!(:employee_user2)  { create(:user, password: password) }
  let!(:employee_subscription2) { create(:subscription, user_id: employee_user2.id, last_payment_date: DateTime.now)}
  let!(:employee2) { create(:employee, user_id: employee_user2.id) }
  let(:employee_id2) { employee2.user_id }

  let!(:company_user)  { create(:user, password: password) }
  let!(:company_subscription) { create(:subscription, user_id: company_user.id, last_payment_date: DateTime.now)}
  let!(:company) { create(:company, user_id: company_user.id) }
  let(:company_id) { company.user_id }

  let!(:employee_offer1) { create(:employee_offer, employee_id: employee.id, company_id: company.id) }
  let!(:employee_offer2) { create(:employee_offer, employee_id: employee.id, company_id: company.id) }

  let(:valid_attributes) { { employee_id: employee_user.id, description: "Description", position: "Position" } }
  let(:without_position) { { employee_id: employee_user.id, description: "Description" } }

  # Test suite for GET /employees/1/employee_offers
  describe 'GET /employees/1/employee_offers' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: employee_user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers", headers: { 'Authorization': token }
      end

      it "return all employee offers" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(2)
        expect(json['items'].size).to eq(2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: employee_user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers", params: { limit: 1 }, headers: { 'Authorization': token }
      end

      it "returns 1 employee offer" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(2)
        expect(json['items'].size).to eq(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: employee_user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers", params: { offset: 1 }, headers: { 'Authorization': token }
      end

      it "returns employee offer" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(2)
        expect(json['items'].size).to eq(1)
        expect(json['items'][0]['id']).to eq(employee_offer2.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not payed' do
      before do
        employee_subscription.last_payment_date = 1.month.ago - 1.day
        employee_subscription.save

        post "/auth/login", params: { email: employee_user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not my offers' do
      before do
        post "/auth/login", params: { email: employee_user2.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when i am not employee' do
      before do
        post "/auth/login", params: { email: company_user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before do
        get "/employees/#{employee_id}/employee_offers"
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for GET /employees/1/employee_offers/1
  describe 'GET /employees/1/employee_offers/1' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: employee_user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers/#{employee_offer1.id}", headers: { 'Authorization': token }
      end

      it "return all employee offer" do
        expect(json['id']).to match(employee_offer1.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not payed' do
      before do
        employee_subscription.last_payment_date = 1.month.ago - 1.day
        employee_subscription.save

        post "/auth/login", params: { email: employee_user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers/#{employee_offer1.id}", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not my offers' do
      before do
        post "/auth/login", params: { email: employee_user2.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers/#{employee_offer1.id}", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when offer not exists' do
      let(:employee_offer_id) { 0 }

      before do
        post "/auth/login", params: { email: employee_user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}/employee_offers/#{employee_offer_id}", headers: { 'Authorization': token }
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when not authorized' do
      before do
        get "/employees/#{employee_id}/employee_offers/#{employee_offer1.id}"
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /employees/:employee_id/employee_offers/
  describe 'POST /employees/:employee_id/employee_offers' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: company_user.email, password: password}
        token = json['token']

        post "/employees/#{employee_id}/employee_offers", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates an offer' do
        expect(json['description']).to eq('Description')
        expect(json['position']).to eq('Position')
        expect(json['employee_id']).to eq(employee_user.id)
        expect(json['company_id']).to eq(company_user.id)
        expect(employee.employee_offers).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request without position' do
      before do
        post "/auth/login", params: { email: company_user.email, password: password}
        token = json['token']

        post "/employees/#{employee_id}/employee_offers", params: without_position, headers: { 'Authorization': token }
      end

      it 'returns error message' do
        expect(response.body).to match("{\"position\":[\"can't be blank\"]}")
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when the employee not exists' do
      let(:employee_id) { 0 }
      before do
        post "/auth/login", params: { email: company_user.email, password: password}
        token = json['token']

        post "/employees/#{employee_id}/employee_offers", params: without_position, headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when the request from not a company' do
      before do
        post "/auth/login", params: { email: employee_user.email, password: password}
        token = json['token']

        post "/employees/#{employee_id}/employee_offers", params: without_position, headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the user not payed' do
      before do
        company_subscription.last_payment_date = 1.month.ago - 1.day
        company_subscription.save

        post "/auth/login", params: { email: company_user.email, password: password}
        token = json['token']

        post "/employees/#{employee_id}/employee_offers", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the user not authorized' do
      before do
        post "/employees/#{employee_id}/employee_offers", params: valid_attributes
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end
end
