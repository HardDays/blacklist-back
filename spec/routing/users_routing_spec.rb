require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(:get => "users/1").to route_to("users#show", id: "1")
    end

    it "routes to #my" do
      expect(:get => "/users/my").to route_to("users#my")
    end

    it "routes to #create" do
      expect(:post => "/users").to route_to("users#create")
    end

    it "routes to #update" do
      expect(:patch => "/users/1").to route_to("users#update", id: "1")
    end

    it "routes to #verify_code" do
      expect(:post => "/users/verify_code").to route_to("users#verify_code")
    end

    it "routes to #invite" do
      expect(:post => "/users/invite").to route_to("users#invite")
    end
  end
end
