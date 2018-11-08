require "rails_helper"

RSpec.describe VacancyResponsesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/vacancies/1/vacancy_responses").to route_to("vacancy_responses#index", :vacancy_id => "1")
    end

    it "routes to #create" do
      expect(:post => "/vacancies/1/vacancy_responses").to route_to("vacancy_responses#create", :vacancy_id => "1")
    end
  end
end
