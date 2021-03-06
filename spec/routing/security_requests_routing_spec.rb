require "rails_helper"

RSpec.describe SecurityRequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/security_requests").to route_to("security_requests#index")
    end

    it "routes to #show" do
      expect(:get => "/security_requests/1").to route_to("security_requests#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/security_requests").to route_to("security_requests#create")
    end
  end
end
