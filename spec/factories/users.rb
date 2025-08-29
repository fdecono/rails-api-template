FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    # You can create different types of users
    factory :admin_user do
      admin { true }
    end

    factory :confirmed_user do
      confirmed_at { Time.current }
    end

    # Factory for creating users with password confirmation (for POST requests)
    factory :user_with_confirmation, parent: :user do
      password_confirmation { password }
    end
  end
end
