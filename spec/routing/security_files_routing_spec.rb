require "rails_helper"

RSpec.describe SecurityFilesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/security_files").to route_to("security_files#index")
    end

    it "routes to #show" do
      expect(:get => "/security_files/1").to route_to("security_files#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/security_files").to route_to("security_files#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/security_files/1").to route_to("security_files#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/security_files/1").to route_to("security_files#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/security_files/1").to route_to("security_files#destroy", :id => "1")
    end
  end
end
