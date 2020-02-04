# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
hotel = Hotel.where(external_id: 'dummy-hotel-1', phone: '+1 (123) 123-1234').first_or_create!(name: 'Test Hotel')

2.times do |i|
  User.where(email: "user#{i + 1}+hotel@example.org").first_or_create!(
    password:              'pass1234',
    password_confirmation: 'pass1234',
    profile:               { name: "User##{i + 1}" },
    hotel: hotel
  )
end
