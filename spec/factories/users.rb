FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    confirmation_token { Faker::Number.number(4).to_s }
    confirmation_sent_at { DateTime.now }
  end
end