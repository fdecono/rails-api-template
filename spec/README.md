# RSpec Testing Guide

This directory contains the test suite for the Rails API Template application, configured with RSpec, FactoryBot, and shoulda-matchers.

## Directory Structure

```
spec/
├── factories/           # FactoryBot factory definitions
├── models/             # Model specifications
├── shared_examples/    # Reusable test examples
├── shared_contexts/    # Reusable test contexts
├── rails_helper.rb     # Rails-specific RSpec configuration
└── spec_helper.rb      # Basic RSpec configuration
```

## Shared Examples

### Syntax Options

RSpec provides two ways to include shared examples:

- **`include_examples`** - Emphasizes that you're including test examples (RECOMMENDED)
- **`it_behaves_like`** - Emphasizes that your object behaves like something with certain characteristics

Both work identically - `include_examples` is recommended as it's more explicit about what's happening.

### Using `common validations`

```ruby
RSpec.describe User, type: :model do
  # You can use either syntax - they work identically:

  # Option 1: include_examples (emphasizes including examples) - RECOMMENDED
  include_examples "common validations", User, {
    presence: [:email, :password],
    uniqueness: [:email],
    length: {
      password: { minimum: 8 },
      email: { maximum: 255 }
    },
    numericality: {
      age: { greater_than: 0, only_integer: true }
    }
  }

  # Option 2: it_behaves_like (emphasizes behavior)
  # it_behaves_like "common validations", User, {
  #   presence: [:email, :password],
  #   uniqueness: [:email],
  #   length: {
  #     password: { minimum: 8 },
  #     email: { maximum: 255 }
  #   },
  #   numericality: {
  #     age: { greater_than: 0, only_integer: true }
  #   }
  # }
end
```

### Using `common associations`

```ruby
RSpec.describe Post, type: :model do
  # Both syntaxes work identically:

  include_examples "common associations", Post, {
    belongs_to: [:user],
    has_many: [:comments, :likes],
    has_one: [:featured_image]
  }

  # Or use it_behaves_like:
  # it_behaves_like "common associations", Post, {
  #   belongs_to: [:user],
  #   has_many: [:comments, :likes],
  #   has_one: [:featured_image]
  # }
end
```

### Using `common scopes`

```ruby
RSpec.describe Post, type: :model do
  # Both syntaxes work identically:

  include_examples "common scopes", Post, {
    published: [
      {
        type: :returns_records,
        includes: [published_post],
        excludes: [draft_post]
      }
    ],
    recent: [
      {
        type: :chains_with,
        scope: :published
      }
    ]
  }

  # Or use it_behaves_like:
  # it_behaves_like "common scopes", Post, {
  #   published: [
  #     {
  #       type: :returns_records,
  #       includes: [published_post],
  #       excludes: [draft_post]
  #     }
  #   ],
  #   recent: [
  #     {
  #       type: :chains_with,
  #       scope: :published
      #     }
  #   ]
  # }
end
```

## Shared Contexts

### Using `common setup`

```ruby
RSpec.describe PostsController, type: :controller do
  include_context "common setup"

  before(:each) do
    sign_in(current_user)
    setup_test_data
  end

  after(:each) do
    cleanup_test_data
  end

  # Your tests here...
end
```

### Using `api testing`

```ruby
RSpec.describe "Posts API", type: :request do
  include_context "api testing"
  include_context "common setup"

  before(:each) do
    sign_in(current_user)
  end

  describe "GET /posts" do
    it "returns a list of posts" do
      get_api("/posts", authenticated_headers)
      expect_successful_response
      expect(json_response["posts"]).to be_present
    end
  end
end
```

### Using `database testing`

```ruby
RSpec.describe Post, type: :model do
  include_context "database testing"

  it "can be created and destroyed" do
    post = create_test_record(Post, title: "Test Post")
    expect(count_records(Post)).to eq(1)

    delete_test_record(post)
    expect(count_records(Post)).to eq(0)
  end
end
```

## FactoryBot Usage

### Basic Factories

```ruby
# Create a user
user = create(:user)

# Create a user with specific attributes
user = create(:user, email: "test@example.com")

# Create multiple users
users = create_list(:user, 3)

# Build without saving
user = build(:user)

# Create with associations
post = create(:post, user: user)
```

### Factory Traits

```ruby
# Using traits for different user types
admin = create(:user, :admin)
confirmed_user = create(:user, :confirmed)

# Using traits for different post states
draft_post = create(:post, :draft)
featured_post = create(:post, :featured)
```

## Shoulda Matchers

### Validation Matchers

```ruby
RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_length_of(:password).is_at_least(8) }
  it { should validate_numericality_of(:age).is_greater_than(0) }
end
```

### Association Matchers

```ruby
RSpec.describe Post, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:comments) }
  it { should have_one(:featured_image) }
end
```

## Running Tests

### Run all tests
```bash
bundle exec rspec
```

### Run specific test file
```bash
bundle exec rspec spec/models/user_spec.rb
```

### Run tests with specific pattern
```bash
bundle exec rspec --pattern "spec/models/*_spec.rb"
```

### Run tests with documentation format
```bash
bundle exec rspec --format documentation
```

### Run tests with coverage
```bash
COVERAGE=true bundle exec rspec
```

## Best Practices

1. **Use shared examples** for common validation and association patterns
2. **Use shared contexts** for common setup and helper methods
3. **Keep factories simple** and use traits for variations
4. **Use descriptive test names** that explain the expected behavior
5. **Group related tests** using `describe` and `context` blocks
6. **Use `let` blocks** for test data that might not be used in every test
7. **Use `before` blocks** for setup that's needed in every test
8. **Clean up test data** to avoid test interference

## Adding New Shared Examples

1. Create a new file in `spec/shared_examples/`
2. Define your shared examples using `RSpec.shared_examples`
3. Document the expected parameters and usage
4. Add examples to this README

## Adding New Shared Contexts

1. Create a new file in `spec/shared_contexts/`
2. Define your shared context using `RSpec.shared_context`
3. Document the provided methods and let blocks
4. Add examples to this README
