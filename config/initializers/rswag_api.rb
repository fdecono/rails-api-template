# RSwag API Configuration
if defined?(Rswag::Api)
  Rswag::Api.configure do |c|
    # Set the root path for the Swagger JSON endpoint
    c.openapi_root = Rails.root.to_s + '/swagger'
  end
end
