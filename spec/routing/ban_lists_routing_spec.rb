require "rails_helper"

RSpec.describe BanListsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/black_list").to route_to("ban_lists#index")
    end

    it "routes to #create" do
      expect(:post => "/black_list").to route_to("ban_lists#create")
    end
  end
end
