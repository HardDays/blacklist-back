# require 'rails_helper'
#
# RSpec.describe 'Vacancies API', type: :request do
#Test suite for GET /companies
# describe 'GET /companies' do
#   context 'when simply get' do
#     before { get "/companies" }
#
#     it "return all companies" do
#       expect(json).not_to be_empty
#       expect(json.size).to eq(10)
#     end
#
#     it 'returns status code 200' do
#       expect(response).to have_http_status(200)
#     end
#   end
#
#   context 'when search' do
#     before { get "/companies", params: { text: company.name } }
#
#     it "returns company" do
#       expect(json[0].id).to eq(company.id)
#     end
#
#     it 'returns status code 200' do
#       expect(response).to have_http_status(200)
#     end
#   end
#
#   context 'when use limit' do
#     before { get "/companies", params: { limit: 5 } }
#
#     it "returns company" do
#       expect(json).not_to be_empty
#       expect(json.size).to eq(5)
#     end
#
#     it 'returns status code 200' do
#       expect(response).to have_http_status(200)
#     end
#   end
#
#   context 'when use offset' do
#     before { get "/companies", params: { offset: 2 } }
#
#     it "returns company" do
#       expect(json).not_to be_empty
#       expect(json.size).to eq(8)
#       expect(json[0].id).to eq(companies[2].id)
#     end
#
#     it 'returns status code 200' do
#       expect(response).to have_http_status(200)
#     end
#   end
# end
# end
