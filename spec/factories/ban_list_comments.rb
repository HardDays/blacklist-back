FactoryBot.define do
  factory :ban_list_comment do
    text { Faker::Lorem.paragraph }
    comment_type { Faker::Number.between(0, 1) }
  end
end