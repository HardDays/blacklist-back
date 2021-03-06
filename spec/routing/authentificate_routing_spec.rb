require "rails_helper"

RSpec.describe AuthenticateController, type: :routing do
  describe "routing" do
    it "routes to #login" do
      expect(:post => "/auth/login").to route_to("authenticate#login")
    end

    it "routes to #logout" do
      expect(:post => "/auth/logout").to route_to("authenticate#logout")
    end

    it "routes to #forgot_password" do
      expect(:post => "/auth/forgot_password").to route_to("authenticate#forgot_password")
    end
  end
end
