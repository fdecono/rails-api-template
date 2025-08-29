FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    sequence(:name) { |n| "OAuth App #{n}" }
    redirect_uri { "http://localhost:3000/callback" }
    scopes { "read write" }
    confidential { true }

    # Factory for non-confidential apps (like mobile apps)
    factory :public_oauth_application do
      confidential { false }
    end

    # Factory for admin apps with full scopes
    factory :admin_oauth_application do
      scopes { "read write admin" }
    end

    # Factory for read-only apps
    factory :readonly_oauth_application do
      scopes { "read" }
    end
  end
end
