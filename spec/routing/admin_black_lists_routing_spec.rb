require "rails_helper"

RSpec.describe BanListsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/admin_black_list").to route_to("admin_ban_lists#index")
    end

    it "routes to #approve" do
      expect(:post => "/admin_black_list/1/approve").to route_to("admin_ban_lists#approve", :id => "1")
    end

    it "routes to #deny" do
      expect(:post => "/admin_black_list/1/deny").to route_to("admin_ban_lists#deny", :id => "1")
    end
  end
end
