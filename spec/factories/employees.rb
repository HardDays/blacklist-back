FactoryBot.define do
  factory :employee do
    first_name { Faker::String }
    last_name { Faker::String }
    second_name { Faker::String }
    birthday { DateTime.now }
    gender { Faker::Number.between(0, 1) }
    education { Faker::String }
    education_year { Faker::Number.number(4).to_s}
    contacts { Faker::String }
    skills { Faker::String }
    position { Faker::String }
    experience { Faker::Number.number(3) }
    status { Faker::Number.between(0, 3) }
  end
end