FactoryBot.define do
  factory :auth_user do
    email { Faker::Internet.email }
    password { User.encrypt_password("123123") }
  end
end