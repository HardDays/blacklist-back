FactoryBot.define do
  factory :employee_offer do
    position { Faker::Lorem.word }
  end
end