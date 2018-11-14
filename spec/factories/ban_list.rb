FactoryBot.define do
  factory :ban_list do
    name { Faker::Lorem.word }
    description { Faker::Lorem.word }
    status { Faker::Number.between(0, 2) }
  end
end