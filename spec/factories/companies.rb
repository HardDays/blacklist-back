FactoryBot.define do
  factory :company do
    name { Faker::Lorem.word }
    description { Faker:: Lorem.word }
    contacts { Faker:: Lorem.word }
    address { Faker:: Lorem.word }
  end
end