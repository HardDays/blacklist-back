FactoryBot.define do
  factory :ban_list do
    name { Faker::Lorem.word }
    description { Faker:: Lorem.word }
  end
end