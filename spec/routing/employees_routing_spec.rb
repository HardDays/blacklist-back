require "rails_helper"

RSpec.describe EmployeesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/employees").to route_to("employees#index")
    end

    it "routes to #dashboard" do
      expect(:get => "/employees/dashboard").to route_to("employees#dashboard")
    end

    it "routes to #show" do
      expect(:get => "/employees/1").to route_to("employees#show", id: "1")
    end

    it "routes to #create" do
      expect(:post => "/employees").to route_to("employees#create")
    end

    it "routes to #update" do
      expect(:patch => "/employees/1").to route_to("employees#update", id: "1")
    end
  end
end
