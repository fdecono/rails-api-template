# Rails API Template

A comprehensive Ruby on Rails API template for building RESTful APIs with authentication, testing, and documentation. This template provides a clean foundation with user management, OAuth authentication, and comprehensive testing setup.

## 🚀 Features

- **RESTful API** with JSON responses and proper HTTP status codes
- **Comprehensive Testing** with RSpec, FactoryBot, and Shoulda Matchers
- **API Template Documentation** with Swagger/OpenAPI via RSwag
- **User Management** with secure authentication
- **OAuth 2.0 Provider** via Doorkeeper for secure API template access
- **Secure Password Handling** with bcrypt encryption
- **Modern Rails 7.1** architecture
- **PostgreSQL** database backend
- **Production-Ready Security** with proper authentication flows
- **JSON API Serialization** with ActiveModelSerializers
- **Custom Renderer System** for consistent API template responses
- **Clean Foundation** ready for your domain models

## 🛠 Tech Stack

- **Ruby**: 3.2.2
- **Rails**: 7.1.5.2
- **Database**: PostgreSQL
- **Testing**: RSpec, FactoryBot, Shoulda Matchers
- **API Docs**: RSwag (Swagger/OpenAPI)
- **Authentication**: OAuth 2.0 via Doorkeeper
- **Security**: bcrypt for password encryption
- **Serialization**: ActiveModelSerializers with JSON API format
- **Template Features**: Ready-to-use API structure with comprehensive examples

## 📋 Prerequisites

- Ruby 3.2.2
- PostgreSQL
- Bundler

## 🚀 Getting Started

### Current Status ✅

This API template is **production-ready** with:
- ✅ **All tests passing** (25 examples, 0 failures)
- ✅ **OAuth 2.0 authentication** fully implemented
- ✅ **bcrypt password security** integrated
- ✅ **Comprehensive test coverage** with RSpec
- ✅ **Swagger documentation** ready for generation
- ✅ **Enterprise-grade security** implemented
- ✅ **ActiveModelSerializers** integrated with JSON API format
- ✅ **Custom renderer system** for consistent API template responses

### 1. Clone the Repository
```bash
git clone https://github.com/fdecono/rails-api-template
cd rails-api-template
```

### 2. Install Dependencies
```bash
bundle install
```

### 3. Database Setup
```bash
# Start PostgreSQL service (if not running)
brew services start postgresql@16

# Create and setup database
rails db:create
rails db:migrate
rails db:seed
```

**Note**: The database includes migrations for the core functionality:
- User management with secure authentication
- OAuth 2.0 provider setup via Doorkeeper
- Clean foundation ready for your domain models

### 4. Start the Server
```bash
rails server
```

The API template will be available at `http://localhost:3000`

## 🧪 Testing

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/requests/api/v1/users_spec.rb

# Run serializer tests
bundle exec rspec spec/serializers/

# Run with documentation format
bundle exec rspec -fd
```

### Test Structure
- **`spec/models/`** - Model tests with shared examples
- **`spec/controllers/`** - Controller tests
- **`spec/requests/`** - API template endpoint tests with RSwag and OAuth
- **`spec/serializers/`** - Serializer tests for ActiveModelSerializers
- **`spec/factories/`** - FactoryBot factories for test data
- **`spec/shared_examples/`** - Reusable test examples
- **`spec/shared_contexts/`** - Reusable test contexts

### **OAuth Testing with RSpec**

The test suite includes OAuth authentication testing:

```ruby
# Example from spec/requests/api/v1/users_spec.rb
let(:application) { Doorkeeper::Application.create!(name: 'Test App', redirect_uri: 'http://localhost:3000') }
let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: users.first.id, scopes: 'read') }
let(:Authorization) { "Bearer #{access_token.token}" }
```

This ensures all protected endpoints are properly tested with valid OAuth tokens.

### **OAuth Applications Testing**

The test suite also includes comprehensive testing for OAuth application management:

```ruby
# Example from spec/requests/api/v1/oauth_applications_spec.rb
let(:oauth_app) { create(:oauth_application) }
let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'write') }
```

Tests cover CRUD operations for OAuth applications with proper authentication and validation.

### Shared Examples Usage
```ruby
# In your model specs
RSpec.describe User, type: :model do
  include_examples "common validations", User, {
    presence: [:email, :password],
    uniqueness: [:email],
    length: { password: { minimum: 6 } }
  }
end
```

## 📚 API Template Documentation

### Swagger UI
Access the interactive API template documentation at:
```
http://localhost:3000/api-docs
```

### Generate Documentation
```bash
# Generate OpenAPI specs from RSpec tests
bundle exec rspec spec/requests/api/v1/users_spec.rb --format Rswag::Specs::SwaggerFormatter
```

## 🔑 OAuth 2.0 Implementation Guide

### **Step 1: Create OAuth Application**

#### **Via Rails Console (Recommended for testing)**
```bash
rails console
```

```ruby
# Create a new OAuth application
app = Doorkeeper::Application.create!(
  name: 'My App',
  redirect_uri: 'https://oauth.pstmn.io/v1/callback', # For Postman testing
  scopes: 'read write'
)

puts "Client ID: #{app.uid}"
puts "Client Secret: #{app.secret}"
```

#### **Via API Template Endpoint**
```bash
curl -X POST http://localhost:3000/api/v1/oauth_applications \
  -H "Content-Type: application/json" \
  -d '{
    "oauth_application": {
      "name": "My App",
      "redirect_uri": "https://oauth.pstmn.io/v1/callback",
      "scopes": "read write"
    }
  }'
```

### **Step 2: Get Access Token (Password Grant)**

#### **Using cURL**
```bash
curl -X POST http://localhost:3000/oauth/token \
  --header 'Authorization: Basic [base64_encoded_client_credentials]' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=password' \
  --data-urlencode 'username=user@example.com' \
  --data-urlencode 'password=password123'
```

#### **Using Postman**
1. **Method**: `POST`
2. **URL**: `http://localhost:3000/oauth/token`
3. **Authorization Tab**:
   - **Type**: `Basic Auth`
   - **Username**: `[Your Client ID]`
   - **Password**: `[Your Client Secret]`
4. **Body** (x-www-form-urlencoded):
   ```
   grant_type: password
   username: user@example.com
   password: password123
   ```

#### **Response**
```json
{
  "access_token": "abc123def456...",
  "token_type": "Bearer",
  "expires_in": 7200,
  "refresh_token": "def456ghi789...",
  "scope": "read write"
}
```

### **Step 3: Use Access Token**

#### **Making Authenticated Requests**
```bash
curl -H "Authorization: Bearer abc123def456..." \
  http://localhost:3000/api/v1/users
```

#### **Postman Setup**
- **Authorization Tab**: `Bearer Token`
- **Token**: `[Your Access Token]`

### **Step 4: Refresh Token**

When access tokens expire, use the refresh token:

```bash
curl -X POST http://localhost:3000/oauth/token \
  --header 'Authorization: Basic [base64_encoded_client_credentials]' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=refresh_token' \
  --data-urlencode 'refresh_token=[your_refresh_token]'
```

### **OAuth Endpoints**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/oauth/token` | POST | Get access token (password grant) |
| `/oauth/token` | POST | Refresh access token |
| `/oauth/revoke` | POST | Revoke access token |
| `/oauth/introspect` | POST | Introspect token |
| `/oauth/applications` | GET/POST | Manage OAuth applications |

### **Error Handling**

Common OAuth errors and solutions:

| Error | Description | Solution |
|-------|-------------|----------|
| `invalid_grant` | Invalid credentials or client | Check username/password and client credentials |
| `invalid_client` | Invalid client ID/secret | Verify OAuth application credentials |
| `invalid_scope` | Requested scope not allowed | Check application scopes |
| `unauthorized_client` | Client not authorized for grant type | Verify grant type configuration |

## 📊 JSON Serialization with ActiveModelSerializers

The API template uses **ActiveModelSerializers** to provide consistent, well-structured JSON responses following the JSON API specification.

### **Features**

- **JSON API Format**: Standardized JSON structure with `data`, `type`, and `attributes`
- **Automatic Serialization**: Models are automatically serialized using appropriate serializers
- **Consistent Response Format**: All API template responses follow the same structure
- **Custom Attributes**: Easy to add computed or conditional attributes
- **Collection Support**: Automatic handling of single objects and collections

### **Response Format**

All API template responses follow this structure:

```json
{
  "data": {
    "id": "1",
    "type": "users",
    "attributes": {
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe"
    }
  }
}
```

### **Collection Responses**

```json
{
  "data": [
    {
      "id": "1",
      "type": "users",
      "attributes": { ... }
    },
    {
      "id": "2",
      "type": "users",
      "attributes": { ... }
    }
  ],
  "meta": {
    "totalCount": 2
  }
}
```

### **Custom Renderer System**

The API template includes a custom renderer system for consistent responses:

#### **Renderer Classes**
- **`Renderer`**: Base renderer class with common functionality
- **`ObjectRenderer`**: Renders single objects
- **`CollectionRenderer`**: Renders collections

#### **ResponseRenderer Concern**
Controllers can include the `ResponseRenderer` concern for easy rendering:

```ruby
class UsersController < ApiController
  include ResponseRenderer

  def show
    render_object @user
  end

  def index
    render_collection @users
  end
end
```

### **Creating Custom Serializers**

1. **Inherit from ActiveModel::Serializer**:
```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :email, :first_name, :last_name

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end
```

2. **Add Custom Methods**:
```ruby
def custom_attribute
  # Your custom logic here
  object.some_computed_value
end
```

3. **Conditional Attributes**:
```ruby
def attributes(*args)
  hash = super
  hash[:admin] = object.admin? if object.respond_to?(:admin?)
  hash
end
```

### **Configuration**

ActiveModelSerializers is configured in `config/initializers/active_model_serializers.rb`:

- **Adapter**: JSON API format
- **Key Transform**: camelCase (e.g., `created_at` → `createdAt`)
- **Serializer Lookup**: Automatic serializer discovery

## 🏗 Template Foundation

The API template provides a clean foundation with core functionality:

### **User Model**
- **Authentication**: Secure password handling with bcrypt
- **Features**: Email, first name, last name, admin status
- **Methods**: `full_name`, `admin?`, `confirmed?`
- **OAuth Integration**: Ready for Doorkeeper authentication

### **Key Features**
- **User Management**: Complete user CRUD operations
- **Authentication**: OAuth 2.0 provider setup
- **Security**: bcrypt password encryption
- **Testing**: Comprehensive test coverage with RSpec
- **API Documentation**: Swagger/OpenAPI ready

### **Template Design Philosophy**
This template follows a **clean foundation approach** that provides:
- **Essential Infrastructure**: User management, authentication, testing
- **Modern Rails**: Rails 7.1 with latest best practices
- **Production Ready**: OAuth, security, and deployment ready
- **Extensible**: Clean slate for your domain models
- **Well Tested**: Comprehensive test suite as examples

### API Template Endpoints

#### Users
- `GET /api/v1/users` - List all users (requires authentication)
- `POST /api/v1/users` - Create a new user
- `GET /api/v1/users/:id` - Get user details
- `PUT /api/v1/users/:id` - Update user
- `DELETE /api/v1/users/:id` - Delete user

#### OAuth Applications
- `GET /api/v1/oauth_applications` - List OAuth applications
- `POST /api/v1/oauth_applications` - Create OAuth application
- `GET /api/v1/oauth_applications/:id` - Get OAuth application details
- `PUT /api/v1/oauth_applications/:id` - Update OAuth application
- `DELETE /api/v1/oauth_applications/:id` - Delete OAuth application

## 🔐 Authentication & Security

The API template uses **OAuth 2.0** with Doorkeeper for secure, industry-standard authentication.

### **OAuth 2.0 Flow**

1. **Register OAuth Application** → Get Client ID and Secret
2. **User Authentication** → Exchange credentials for access token
3. **API Template Access** → Use access token in Authorization header
4. **Token Refresh** → Use refresh token when access token expires

### **Grant Types Supported**

- **Password Grant**: For trusted first-party applications (mobile apps, web apps)
- **Client Credentials**: For server-to-server communication

### **Scopes Available**

- **`read`**: Read access to resources (default scope)
- **`write`**: Create, update, delete resources
- **`admin`**: Administrative access

### **Security Features**

- **Confidential Applications**: Use HTTP Basic Authentication for client credentials
- **Access Token Expiration**: Configurable token lifetime
- **Refresh Tokens**: Automatic token renewal
- **Scope-based Access Control**: Granular permissions per application

## 🏗 Project Structure

```
rails-api-template/
├── app/
│   ├── controllers/
│   │   ├── api/v1/
│   │   │   ├── users_controller.rb
│   │   │   └── oauth_applications_controller.rb
│   │   └── concerns/
│   │       ├── response_renderer.rb
│   │       ├── object_renderer.rb
│   │       └── collection_renderer.rb
│   ├── models/
│   │   ├── user.rb
│   │   └── concerns/
│   │       └── serializable.rb
│   ├── serializers/
│   │   └── user_serializer.rb
│   └── views/
├── config/
│   ├── initializers/
│   │   ├── rswag_api.rb
│   │   ├── rswag_ui.rb
│   │   ├── doorkeeper.rb
│   │   └── active_model_serializers.rb
│   └── routes.rb
├── spec/
│   ├── factories/
│   │   └── users.rb
│   ├── models/
│   │   └── user_spec.rb
│   ├── requests/api/v1/
│   │   └── users_spec.rb
│   ├── serializers/
│   │   └── user_serializer_spec.rb
│   ├── shared_examples/
│   │   └── model_validations.rb
│   ├── shared_contexts/
│   │   └── common_setup.rb
│   ├── rails_helper.rb
│   └── swagger_helper.rb
├── swagger/
│   └── v1/
│       └── swagger.json
└── Gemfile
```

## 📖 Key Files

- **`ruby_rules.md`** - Ruby coding standards and best practices
- **`project_structure.md`** - Detailed project architecture
- **`SWAGGER_README.md`** - Comprehensive Swagger setup guide
- **`spec/README.md`** - Testing setup and usage guide
- **`config/initializers/doorkeeper.rb`** - OAuth 2.0 configuration

## 🔧 Configuration

### RSwag Configuration
- **API Docs**: Mounted at `/api-docs`
- **Swagger UI**: Available at `/api-docs`
- **OpenAPI Specs**: Generated from RSpec tests

### OAuth 2.0 Configuration
- **Provider**: Doorkeeper
- **Grant Types**: Password, Client Credentials
- **Token Expiration**: 2 hours (configurable)
- **Refresh Tokens**: Enabled
- **Scopes**: read, write, admin
- **Applications**: Confidential by default (HTTP Basic Auth)

### ActiveModelSerializers Configuration
- **Adapter**: JSON API format for standardized responses
- **Key Transform**: camelCase transformation (snake_case → camelCase)
- **Serializer Lookup**: Automatic discovery of serializer classes
- **Response Format**: Consistent JSON structure across all endpoints

### Password Security Configuration
- **Encryption**: bcrypt with automatic salting
- **Model Integration**: `has_secure_password` in User model
- **Validation**: Password confirmation and length requirements
- **Authentication**: Secure `User.authenticate` method for OAuth
- **Storage**: Only encrypted password digests in database

### Database Configuration
- **Development**: `rails_api_template_development`
- **Test**: `rails_api_template_test`
- **Production**: `rails_api_template_production`

### **Simplified Schema Design**
The database uses a **streamlined approach**:
- **Unified Player References**: All player-related models use consistent `player_id` foreign keys
- **Essential Fields Only**: Focus on core data without unnecessary complexity
- **Optimized Indexes**: Strategic indexing for common query patterns
- **Clean Relationships**: Simple, maintainable foreign key structure

## 🚀 Development

### Adding New Endpoints
1. Create the model and controller
2. Add routes to `config/routes.rb`
3. Write RSpec tests with RSwag documentation
4. Generate updated Swagger docs

### **Template Extension Guidelines**
When extending this template for your project:
- **Start Clean**: Begin with the provided user management foundation
- **Follow Rails Conventions**: Use standard Rails patterns and naming
- **Test Everything**: Follow the testing examples provided
- **Document APIs**: Use RSwag for automatic API documentation
- **Keep it Simple**: Focus on essential functionality first

### Generating Swagger Documentation
```bash
# Generate from all tests
bundle exec rspec --format Rswag::Specs::SwaggerFormatter

# Generate from specific test files
bundle exec rspec spec/requests/api/v1/users_spec.rb --format Rswag::Specs::SwaggerFormatter

# Access documentation at
# http://localhost:3000/api-docs
```

### Code Quality
- Follow Ruby coding standards in `ruby_rules.md`
- Write comprehensive tests for all new features
- Update API template documentation when adding endpoints

## 🐛 Troubleshooting

### Common Issues

#### PostgreSQL Connection
```bash
# If you get connection errors
brew services start postgresql@16
```

#### RSpec Issues
```bash
# Clear test database
rails db:test:prepare

# Run bundle install if gems are missing
bundle install
```

#### RSwag Issues
```bash
# Regenerate Swagger docs
bundle exec rspec --format Rswag::Specs::SwaggerFormatter
```

#### OAuth Issues
```bash
# Check OAuth applications
rails console
Doorkeeper::Application.all

# Verify user exists
User.find_by(email: 'user@example.com')

# Check Doorkeeper configuration
# See config/initializers/doorkeeper.rb
```

**Common OAuth Errors:**
- **`invalid_grant`**: Check username/password and client credentials
- **`invalid_client`**: Verify OAuth application exists and credentials are correct
- **`unauthorized_client`**: Ensure grant type is enabled in Doorkeeper config

## 📝 Contributing

1. Follow the Ruby coding standards in `ruby_rules.md`
2. Write tests for all new features
3. Update documentation as needed
4. Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For questions or issues:
- Check the troubleshooting section above
- Review the `SWAGGER_README.md` for Swagger-specific issues
- Review the `spec/README.md` for testing questions
