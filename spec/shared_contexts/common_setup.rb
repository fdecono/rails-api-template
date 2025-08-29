# Shared context for common test setup
# This provides common setup and helper methods for tests

RSpec.shared_context "common setup" do
  # Common let blocks that can be used across tests
  let(:current_user) { create(:user) }
  let(:admin_user) { create(:admin_user) }

  # Helper methods for common test operations
  def sign_in(user)
    # This would be implemented based on your authentication system
    # For example, with Devise:
    # sign_in user
    # For now, we'll just set a current_user variable
    @current_user = user
  end

  def sign_out
    # This would be implemented based on your authentication system
    # For example, with Devise:
    # sign_out @current_user
    @current_user = nil
  end

  def json_response
    JSON.parse(response.body)
  end

  def api_headers
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def authenticated_headers(user = current_user)
    api_headers.merge(
      'Authorization' => "Bearer #{user.generate_token}" # Adjust based on your auth system
    )
  end

  # Common test data setup
  def setup_test_data
    # Create any common test data needed across multiple tests
    @users = create_list(:user, 3)
    @posts = @users.map { |user| create(:post, user: user) }
  end

  # Clean up test data
  def cleanup_test_data
    # Clean up any test data created during tests
    User.destroy_all
    Post.destroy_all
  end
end

# Shared context for API testing
RSpec.shared_context "api testing" do
  # Common setup for API tests
  let(:api_version) { 'v1' }
  let(:base_url) { "/api/#{api_version}" }

  # Helper methods for API requests
  def get_api(path, headers = api_headers)
    get "#{base_url}#{path}", headers: headers
  end

  def post_api(path, params = {}, headers = api_headers)
    post "#{base_url}#{path}", params: params.to_json, headers: headers
  end

  def put_api(path, params = {}, headers = api_headers)
    put "#{base_url}#{path}", params: params.to_json, headers: headers
  end

  def delete_api(path, headers = api_headers)
    delete "#{base_url}#{path}", headers: headers
  end

  # Common API response expectations
  def expect_successful_response
    expect(response).to have_http_status(:success)
  end

  def expect_created_response
    expect(response).to have_http_status(:created)
  end

  def expect_not_found_response
    expect(response).to have_http_status(:not_found)
  end

  def expect_unauthorized_response
    expect(response).to have_http_status(:unauthorized)
  end

  def expect_forbidden_response
    expect(response).to have_http_status(:forbidden)
  end

  def expect_unprocessable_entity_response
    expect(response).to have_http_status(:unprocessable_entity)
  end
end

# Shared context for database testing
RSpec.shared_context "database testing" do
  # Common database setup and teardown
  before(:each) do
    # Ensure database is clean before each test
    DatabaseCleaner.clean_with(:truncation)
  end

  after(:each) do
    # Clean up after each test
    DatabaseCleaner.clean_with(:truncation)
  end

  # Helper methods for database operations
  def count_records(model_class)
    model_class.count
  end

  def find_record(model_class, id)
    model_class.find(id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def create_test_record(model_class, attributes = {})
    model_class.create!(attributes)
  end

  def update_test_record(record, attributes = {})
    record.update!(attributes)
    record.reload
  end

  def delete_test_record(record)
    record.destroy!
  end
end
