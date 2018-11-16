require 'rails_helper'

RSpec.describe 'Employee API', type: :request do
  let(:date_time) { Time.now }
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, is_payed: true) }
  let!(:employee) { create(:employee, user_id: user.id, status: "approved") }
  let(:employee_id) { employee.user_id }

  let!(:user2)  { create(:user, password: password) }
  let!(:employee2) { create(:employee, user_id: user2.id, status: "approved") }
  let(:employee_id2) { employee2.user_id }

  let!(:user3)  { create(:user, password: password) }
  let!(:employee3) { create(:employee, user_id: user3.id, status: "approved") }
  let(:employee_id3) { employee3.user_id }

  let!(:user4)  { create(:user, password: password) }
  let!(:employee4) { create(:employee, user_id: user4.id, status: "denied") }
  let(:employee_id4) { employee4.user_id }

  let!(:user5)  { create(:user, password: password) }
  let!(:employee5) { create(:employee, user_id: user5.id, status: "added") }
  let(:employee_id5) { employee5.user_id }

  let(:valid_attributes) { { id: user.id, first_name: "First name", last_name: "Last name",
                             second_name: "Second name", birthday: date_time, gender: "m",
                             education: "Education", education_year: 2013, contacts: "Contacts",
                             skills: "Skills", experience: 10, status: "added", position: "Position" } }
  let(:without_first_name) { { id: user.id, last_name: "Last name",
                               second_name: "Second name", birthday: date_time, gender: "m",
                               education: "Education", education_year: 2013, contacts: "Contacts",
                               skills: "Skills", experience: 10, status: "added", position: "Position" } }
  let(:without_last_name) { { id: user.id, first_name: "First name",
                                second_name: "Second name", birthday: date_time, gender: "m",
                                education: "Education", education_year: 2013, contacts: "Contacts",
                                skills: "Skills", experience: 10, status: "added", position: "Position" } }
  let(:without_second_name) { { id: user.id, first_name: "First name", last_name: "Last name",
                              birthday: date_time, gender: "m",
                              education: "Education", education_year: 2013, contacts: "Contacts",
                              skills: "Skills", experience: 10, status: "added", position: "Position" } }

  # Test suite for GET /employees
  describe 'GET /employees' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees", headers: { 'Authorization': token }
      end

      it "return all approved employees" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search first_name' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees", params: { text: employee.first_name}, headers: { 'Authorization': token }
      end

      it "returns employee" do
        expect(json['count']).to eq(3)
        expect(json['items'][0]['id']).to eq(employee_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search second_name' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees", params: { text: employee.second_name }, headers: { 'Authorization': token }
      end

      it "returns employee" do
        expect(json['count']).to eq(3)
        expect(json['items'][0]['id']).to eq(employee_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when search last_name' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees", params: { text: employee.last_name}, headers: { 'Authorization': token }
      end

      it "returns employee" do
        expect(json['count']).to eq(3)
        expect(json['items'][0]['id']).to eq(employee_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees", params: { limit: 1 }, headers: { 'Authorization': token }
      end

      it "returns 2 employee" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees", params: { offset: 1 }, headers: { 'Authorization': token }
      end

      it "returns employees" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
        expect(json['items'][0]['id']).to eq(employee_id2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not payed' do
      before do
        user.is_payed = false
        user.save

        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees", headers: { 'Authorization': token }
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
        get "/employees"
      end

      it "return nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end


  # Test suite for GET /employees/:id
  describe 'GET /employees/:id' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}", headers: { 'Authorization': token }
      end

      it 'returns the employee' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(employee_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record not approved' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id4}", headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when my record not approved' do
      before do
        employee.status = "added"
        employee.save

        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}", headers: { 'Authorization': token }
      end

      it 'i still have access' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(employee_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user not payed' do
      before do
        user2.is_payed = false
        user2.save

        post "/auth/login", params: { email: user2.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}", headers: { 'Authorization': token }
      end

      it 'returns empty message' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when i did not payed' do
      before do
        user.is_payed = false
        user.save

        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}", headers: { 'Authorization': token }
      end

      it 'i still have access' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(employee_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:employee_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = json['token']

        get "/employees/#{employee_id}", headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when not authorized' do
      before do
        get "/employees/#{employee_id}"
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /employees/
  describe 'POST /employees' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/employees", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates an employee' do
        expect(json['first_name']).to eq('First name')
        expect(json['second_name']).to eq('Second name')
        expect(json['last_name']).to eq('Last name')
        expect(Time.parse(json['birthday']).utc.to_s).to eq(date_time.utc.to_s)
        expect(json['gender']).to eq('m')
        expect(json['education']).to eq('Education')
        expect(json['education_year']).to eq("2013")
        expect(json['contacts']).to eq('Contacts')
        expect(json['skills']).to eq('Skills')
        expect(json['experience']).to eq(10)
        expect(json['status']).to eq('added')
        expect(json['position']).to eq('Position')
        expect(json['id']).to eq(user.id)
        expect(user.employee).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request without first name' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/employees", params: without_first_name, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"first_name\":[\"can't be blank\"]}")
      end
    end

    context 'when the request without second name' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/employees", params: without_second_name, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"second_name\":[\"can't be blank\"]}")
      end
    end

    context 'when the request without last name' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/employees", params: without_last_name, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"last_name\":[\"can't be blank\"]}")
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/employees", params: valid_attributes
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for PATCH /employees/:id
  describe 'PATCH /employees/:id' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/employees/#{employee_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'sets fields' do
        expect(json['first_name']).to eq('First name')
        expect(json['second_name']).to eq('Second name')
        expect(json['last_name']).to eq('Last name')
        expect(Time.parse(json['birthday']).utc.to_s).to eq(date_time.utc.to_s)
        expect(json['gender']).to eq('m')
        expect(json['education']).to eq('Education')
        expect(json['education_year']).to eq("2013")
        expect(json['contacts']).to eq('Contacts')
        expect(json['skills']).to eq('Skills')
        expect(json['experience']).to eq(10)
        expect(json['status']).to eq('added')
        expect(json['position']).to eq('Position')
        expect(json['id']).to eq(user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when employee doesn\'t exists' do
      let(:employee_id) { 0 }

      before do
        post "/users/verify_code", params: { code: user.confirmation_token, email: user.email }
        token = json['token']

        patch "/employees/#{employee_id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns empty response' do
        expect(response.body).to match("")
      end
    end

    context 'when the request without authorization' do
      before { patch "/employees/#{employee_id}", params: valid_attributes }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end
  end
end
