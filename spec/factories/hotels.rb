FactoryGirl.define do
  factory :hotel do
    sequence(:external_id) { |i| "hotel-dummy-#{i}" }
    sequence(:name) { |i| "Hotel #{i}" }
    sequence(:phone) { |i| i }
  end
end
