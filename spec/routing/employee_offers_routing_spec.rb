require "rails_helper"

RSpec.describe EmployeeOffersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/employees/1/employee_offers").to route_to("employee_offers#index", :employee_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/employees/1/employee_offers/1").to route_to("employee_offers#show", :employee_id => "1", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/employees/1/employee_offers").to route_to("employee_offers#create", :employee_id => "1")
    end
  end
end
