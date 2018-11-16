FactoryBot.define do
  factory :employee_comment do
    text { Faker::Lorem.paragraph }
    comment_type { Faker::Number.between(0, 1) }
  end
end