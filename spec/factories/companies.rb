FactoryBot.define do
  factory :company do
    name { Faker::String }
    description { Faker:: String }
    contacts { Faker:: String }
    address { Faker:: String }
  end
end