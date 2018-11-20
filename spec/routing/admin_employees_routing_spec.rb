require "rails_helper"

RSpec.describe AdminEmployeesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/admin_employees").to route_to("admin_employees#index")
    end

    it "routes to #show" do
      expect(:get => "/admin_employees/1").to route_to("admin_employees#show", :id => "1")
    end

    it "routes to #approve" do
      expect(:post => "/admin_employees/1/approve").to route_to("admin_employees#approve", :id => "1")
    end

    it "routes to #deny" do
      expect(:post => "/admin_employees/1/deny").to route_to("admin_employees#deny", :id => "1")
    end
  end
end
