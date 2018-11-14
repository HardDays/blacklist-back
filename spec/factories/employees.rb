FactoryBot.define do
  factory :employee do
    first_name { Faker::Lorem.word }
    last_name { Faker::Lorem.word }
    second_name { Faker::Lorem.word }
    birthday { DateTime.now }
    gender { Faker::Number.between(0, 1) }
    education { Faker::Lorem.word }
    education_year { Faker::Number.number(4).to_s}
    contacts { Faker::Lorem.word }
    skills { Faker::Lorem.word }
    position { Faker::Lorem.word }
    experience { Faker::Number.number(3) }
    status { Faker::Number.between(0, 2) }
  end
end