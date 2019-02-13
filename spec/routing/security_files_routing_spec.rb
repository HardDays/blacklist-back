require "rails_helper"

RSpec.describe SecurityFilesController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(:get => "/security_files/1").to route_to("security_files#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/security_files").to route_to("security_files#create")
    end
  end
end
