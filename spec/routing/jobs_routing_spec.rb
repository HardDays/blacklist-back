require "rails_helper"

RSpec.describe JobsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/employees/1/jobs").to route_to("jobs#create", employee_id: "1")
    end

    it "routes to #update" do
      expect(:patch => "/employees/1/jobs/1").to route_to("jobs#update", employee_id: "1", id: "1")
    end
  end
end
