FactoryBot.define do
  factory :boxoffice_seat do
    association :event

    seat_section { Faker::Lorem.word }
    booked_count { Faker::Number.digit }
  end
end