require "rails_helper"

RSpec.describe EmployeeCommentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/employees/1/employee_comments").to route_to("employee_comments#index", :employee_id => "1")
    end

    it "routes to #create" do
      expect(:post => "/employees/1/employee_comments").to route_to("employee_comments#create", :employee_id => "1")
    end
  end
end
