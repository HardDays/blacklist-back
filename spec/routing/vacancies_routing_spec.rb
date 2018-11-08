require "rails_helper"

RSpec.describe VacanciesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/vacancies").to route_to("vacancies#index")
    end

    it "routes to #show" do
      expect(:get => "/vacancies/1").to route_to("vacancies#show", id: "1")
    end

    it "routes to #create" do
      expect(:post => "/companies/1/vacancies").to route_to("vacancies#create", company_id: "1")
    end

    it "routes to #update" do
      expect(:patch => "/companies/1/vacancies/1").to route_to("vacancies#update", company_id: "1", id: "1")
    end
  end
end
