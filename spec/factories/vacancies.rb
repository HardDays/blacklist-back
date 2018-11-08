FactoryBot.define do
  factory :vacancy do
    position { Faker::String }
    description { Faker::String }
  end
end