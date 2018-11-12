FactoryBot.define do
  factory :job do
    name { Faker::Lorem.word }
    period { Faker::Lorem.word }
  end
end