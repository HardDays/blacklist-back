require 'rails_helper'

RSpec.describe 'Job API', type: :request do
  let(:date_time) { Time.now }
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password) }
  let!(:employee) { create(:employee, user_id: user.id) }
  let(:employee_id) { employee.user_id }
  let!(:job) { create(:job, employee_id: employee.id) }
  let(:job_id) { job.id }


  let(:valid_attributes) { { employee_id: user.id, name: "Name", period: "Period",
                             description: "Description", position: "Position" } }
  let(:without_name) { { employee_id: user.id, period: "Period",
                               description: "Description", position: "Position" } }

  # Test suite for POST /employees/:employee_id/jobs/
  describe 'POST /employees/:employee_id/jobs' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/employees/#{employee_id}/jobs", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates an job' do
        expect(json['name']).to eq('Name')
        expect(json['period']).to eq('Period')
        expect(json['description']).to eq('Description')
        expect(json['position']).to eq('Position')
        expect(json['employee_id']).to eq(user.id)
        expect(employee.jobs).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request without name' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/employees/#{employee_id}/jobs", params: without_name, headers: { 'Authorization': token }
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
        post "/employees/#{employee_id}/jobs", params: valid_attributes
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for PATCH /employees/:employee_id/jobs/:id
  describe 'PATCH /employees/:employee_id/jobs/:id' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/employees/#{employee_id}/jobs/#{job_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'sets fields' do
        expect(json['name']).to eq('Name')
        expect(json['period']).to eq('Period')
        expect(json['description']).to eq('Description')
        expect(json['position']).to eq('Position')
        expect(json['employee_id']).to eq(user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when job doesn\'t exists' do
      let(:job_id) { 100 }

      before do
        post "/users/verify_code", params: { code: user.confirmation_token, email: user.email }
        token = json['token']

        patch "/employees/#{employee_id}/jobs/#{job_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns empty response' do
        expect(response.body).to match("")
      end
    end

    context 'when the request without authorization' do
      before { patch "/employees/#{employee_id}/jobs/#{job_id}", params: valid_attributes }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end
end
