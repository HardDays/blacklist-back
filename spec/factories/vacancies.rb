FactoryBot.define do
  factory :vacancy do
    position { Faker::Lorem.word }
    description { Faker::Lorem.word }
  end
end