require "rails_helper"

RSpec.describe AdminBanListCommentsController, type: :routing do
  describe "routing" do
    it "routes to #destroy" do
      expect(:delete => "/admin_black_list_comments/1").to route_to("admin_ban_list_comments#destroy", :id => "1")
    end
  end
end
