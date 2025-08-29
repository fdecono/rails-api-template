# RSwag UI Configuration
if defined?(Rswag::Ui)
  Rswag::Ui.configure do |c|
    # Set the Swagger UI endpoint
    c.openapi_endpoint '/api-docs/v1/swagger.json', 'API V1 Docs'
  end
end
