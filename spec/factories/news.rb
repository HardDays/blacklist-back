FactoryBot.define do
  factory :news do
    text { Faker::Lorem.paragraph }
  end
end