FactoryBot.define do
  factory :image do
    base64 { Faker::String }
  end
end