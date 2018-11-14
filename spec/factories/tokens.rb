FactoryBot.define do
  factory :token do
    info { Faker::Lorem.word }
  end
end