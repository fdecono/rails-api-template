Rails.application.routes.draw do
  use_doorkeeper
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # API Documentation with Swagger (only in development/test)
  if Rails.env.development? || Rails.env.test?
    begin
      mount Rswag::Ui::Engine => '/api-docs'
      mount Rswag::Api::Engine => '/api-docs'
    rescue NameError
      # RSwag gems not loaded, skip mounting
    end
  end

  # API Routes
  namespace :api do
    namespace :v1 do
      # Your API routes will go here
      resources :users
      resources :oauth_applications
    end
  end

  # Defines the root path route ("/")
  # root "articles#index"
end
