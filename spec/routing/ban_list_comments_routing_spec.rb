require "rails_helper"

RSpec.describe BanListCommentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/black_list/1/black_list_comments").to route_to("ban_list_comments#index", :black_list_id => "1")
    end

    it "routes to #create" do
      expect(:post => "/black_list/1/black_list_comments").to route_to("ban_list_comments#create", :black_list_id => "1")
    end
  end
end
