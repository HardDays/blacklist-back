require "rails_helper"

RSpec.describe ImagesController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(:get => "/images/1").to route_to("images#show", id: "1")
    end

    it "routes to #get_with_size" do
      expect(:get => "/images/1/get_with_size").to route_to("images#get_with_size", id: "1")
    end

    it "routes to #create" do
      expect(:post => "/images").to route_to("images#create")
    end

    it "routes to #destroy" do
      expect(:delete => "/images/1").to route_to("images#destroy", id: "1")
    end
  end
end
