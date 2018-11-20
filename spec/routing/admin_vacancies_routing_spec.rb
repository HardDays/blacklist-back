require "rails_helper"

RSpec.describe AdminVacanciesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/admin_vacancies").to route_to("admin_vacancies#index")
    end

    it "routes to #show" do
      expect(:get => "/admin_vacancies/1").to route_to("admin_vacancies#show", :id => "1")
    end

    it "routes to #approve" do
      expect(:post => "/admin_vacancies/1/approve").to route_to("admin_vacancies#approve", :id => "1")
    end

    it "routes to #deny" do
      expect(:post => "/admin_vacancies/1/deny").to route_to("admin_vacancies#deny", :id => "1")
    end
  end
end
