require 'rails_helper'

RSpec.describe "SecurityRequests", type: :request do
  describe "GET /security_requests" do
    it "works! (now write some real specs)" do
      get security_requests_path
      expect(response).to have_http_status(200)
    end
  end
end
