FactoryBot.define do
  factory :job do
    name { Faker::String }
    period { Faker::String }
  end
end