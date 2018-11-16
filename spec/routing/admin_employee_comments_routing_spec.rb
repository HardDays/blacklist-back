require "rails_helper"

RSpec.describe AdminEmployeeCommentsController, type: :routing do
  describe "routing" do
    it "routes to #destroy" do
      expect(:delete => "/admin_employee_comments/1").to route_to("admin_employee_comments#destroy", :id => "1")
    end
  end
end
