require "rails_helper"

RSpec.describe PaymentsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/payments").to route_to("payments#create")
    end
  end
end
