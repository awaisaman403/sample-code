FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "user#{i}+hotel@example.com" }
    password 'pass1234'
    password_confirmation 'pass1234'
  end
end
