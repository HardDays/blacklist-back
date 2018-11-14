require "rails_helper"

RSpec.describe AdminUsersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/admin_users").to route_to("admin_users#index")
    end

    it "routes to #block" do
      expect(:post => "/admin_users/1/block").to route_to("admin_users#block", :id => "1")
    end
  end
end
