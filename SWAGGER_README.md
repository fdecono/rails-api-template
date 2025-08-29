# Swagger/OpenAPI Documentation Setup

This application uses **RSwag** to automatically generate and maintain Swagger/OpenAPI documentation for your Rails API.

## 🚀 **Quick Start**

### 1. Install Gems
```bash
bundle install
```

### 2. Generate Swagger Documentation
```bash
# Generate the swagger.json file from your specs
bundle exec rswag:specs:swaggerize

# Or run the specs to generate documentation
bundle exec rspec spec/requests/
```

### 3. View Documentation
- **Swagger UI**: Visit `/api-docs` in your browser
- **Raw JSON**: Visit `/api-docs/v1/swagger.json`

## 📁 **File Structure**

```
├── config/
│   ├── initializers/
│   │   ├── rswag_api.rb      # API configuration
│   │   └── rswag_ui.rb       # UI configuration
│   └── routes.rb             # Swagger routes
├── spec/
│   ├── requests/             # API request specs
│   │   └── api/v1/          # Versioned API specs
│   └── swagger_helper.rb     # Swagger configuration
├── swagger/                  # Generated documentation
│   └── v1/
│       └── swagger.json
└── SWAGGER_README.md         # This file
```

## 🔧 **Configuration**

### RSwag API Configuration (`config/initializers/rswag_api.rb`)
- Sets the root path for Swagger JSON endpoints
- Configures Swagger filters

### RSwag UI Configuration (`config/initializers/rswag_ui.rb`)
- Sets the Swagger UI endpoint
- Configures the UI title and theme
- Customizes the user interface

### Routes (`config/routes.rb`)
```ruby
# API Documentation with Swagger
mount Rswag::Ui::Engine => '/api-docs'
mount Rswag::Api::Engine => '/api-docs'
```

## ✍️ **Writing API Documentation**

### Basic Structure
```ruby
require 'swagger_helper'

RSpec.describe 'Your API', type: :request do
  path '/api/v1/endpoint' do
    get 'Description of what this endpoint does' do
      tags 'Tag Name'
      produces 'application/json'

      response '200', 'success description' do
        schema type: :object, properties: { ... }
        run_test!
      end
    end
  end
end
```

### Key Components

#### **Path Definition**
```ruby
path '/api/v1/users/{id}' do
  parameter name: :id, in: :path, type: :integer, required: true
end
```

#### **HTTP Methods**
```ruby
get 'Retrieves a user' do
  # GET endpoint
end

post 'Creates a user' do
  # POST endpoint
end

put 'Updates a user' do
  # PUT endpoint
end

delete 'Deletes a user' do
  # DELETE endpoint
end
```

#### **Parameters**
```ruby
# Query parameters
parameter name: :page, in: :query, type: :integer, required: false

# Path parameters
parameter name: :id, in: :path, type: :integer, required: true

# Body parameters
parameter name: :user, in: :body, schema: { ... }

# Header parameters
parameter name: :Authorization, in: :header, type: :string, required: true
```

#### **Response Schemas**
```ruby
response '200', 'user found' do
  schema type: :object,
         properties: {
           user: {
             type: :object,
             properties: {
               id: { type: :integer },
               email: { type: :string },
               name: { type: :string }
             }
           }
         }

  run_test!
end
```

#### **Authentication**
```ruby
# In your swagger_helper.rb
components: {
  securitySchemes: {
    bearerAuth: {
      type: :http,
      scheme: :bearer,
      bearerFormat: 'JWT'
    }
  }
}

# In your spec
security [bearerAuth: []]
```

## 🧪 **Testing and Generation**

### Generate Documentation from Specs
```bash
# Generate swagger.json from all specs
bundle exec rswag:specs:swaggerize

# Generate from specific spec file
bundle exec rspec spec/requests/api/v1/users_spec.rb --format Rswag::Specs::SwaggerFormatter
```

### Run Specs to Update Documentation
```bash
# Run all request specs
bundle exec rspec spec/requests/

# Run specific API version
bundle exec rspec spec/requests/api/v1/

# Run with Swagger formatter
bundle exec rspec spec/requests/ --format Rswag::Specs::SwaggerFormatter
```

### Validate Swagger JSON
```bash
# Install swagger-cli globally
npm install -g swagger-cli

# Validate your swagger.json
swagger-cli validate swagger/v1/swagger.json
```

## 🌐 **Accessing Documentation**

### Development
- **Swagger UI**: `http://localhost:3000/api-docs`
- **Raw JSON**: `http://localhost:3000/api-docs/v1/swagger.json`

### Production
- **Swagger UI**: `https://yourdomain.com/api-docs`
- **Raw JSON**: `https://yourdomain.com/api-docs/v1/swagger.json`

## 📚 **Best Practices**

### 1. **Consistent Naming**
- Use descriptive endpoint names
- Group related endpoints with tags
- Use consistent parameter naming

### 2. **Comprehensive Documentation**
- Document all possible responses (200, 400, 401, 404, 422, 500)
- Include examples in schemas
- Document required vs optional parameters

### 3. **Schema Reusability**
- Define common schemas in `swagger_helper.rb`
- Reference schemas instead of duplicating definitions
- Use consistent data types

### 4. **Testing Integration**
- Write specs that generate documentation
- Use `run_test!` to execute actual tests
- Validate response schemas

### 5. **Versioning**
- Use API versioning in paths (`/api/v1/`, `/api/v2/`)
- Maintain separate swagger files for each version
- Document breaking changes between versions

## 🔍 **Example: Complete API Endpoint**

```ruby
require 'swagger_helper'

RSpec.describe 'Teams API', type: :request do
  path '/api/v1/teams' do
    get 'Retrieves a list of teams' do
      tags 'Teams'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'

      response '200', 'teams found' do
        schema type: :object,
               properties: {
                 teams: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/Team' }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     total_count: { type: :integer },
                     total_pages: { type: :integer },
                     current_page: { type: :integer }
                   }
                 }
               }

        let(:teams) { create_list(:team, 3) }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end
    end

    post 'Creates a new team' do
      tags 'Teams'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :team, in: :body, schema: {
        type: :object,
        properties: {
          team: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Barcelona FC' },
              city: { type: :string, example: 'Barcelona' },
              country: { type: :string, example: 'Spain' },
              founded_year: { type: :integer, example: 1899 }
            },
            required: ['name', 'city', 'country']
          }
        }
      }

      response '201', 'team created' do
        let(:Authorization) { "Bearer #{generate_token}" }
        let(:team) { { team: { name: 'Test Team', city: 'Test City', country: 'Test Country' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['team']['name']).to eq('Test Team')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{generate_token}" }
        let(:team) { { team: { name: '' } } }

        run_test!
      end
    end
  end
end
```

## 🚨 **Troubleshooting**

### Common Issues

#### **Documentation Not Updating**
- Ensure specs are running and passing
- Check that `swagger_helper.rb` is properly configured
- Verify the swagger directory exists and is writable

#### **Swagger UI Not Loading**
- Check that routes are properly mounted
- Verify the swagger.json file exists and is valid
- Check browser console for JavaScript errors

#### **Schema Validation Errors**
- Ensure all required properties are documented
- Check data types match between specs and schemas
- Validate JSON syntax in swagger.json

### Debug Commands
```bash
# Check if swagger files exist
ls -la swagger/

# Validate swagger JSON
cat swagger/v1/swagger.json | jq '.'

# Check RSpec configuration
bundle exec rspec --dry-run
```

## 📖 **Additional Resources**

- [RSwag Documentation](https://github.com/rswag/rswag)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Swagger UI](https://swagger.io/tools/swagger-ui/)
- [Rails API Documentation](https://guides.rubyonrails.org/api_app.html)

## 🤝 **Contributing**

When adding new API endpoints:

1. **Write the endpoint spec** in `spec/requests/api/v1/`
2. **Document all parameters** and responses
3. **Include examples** in schemas
4. **Test the endpoint** thoroughly
5. **Generate documentation** with `bundle exec rswag:specs:swaggerize`
6. **Validate the swagger.json** file
7. **Update this README** if needed

---

**Happy documenting! 🎯**
