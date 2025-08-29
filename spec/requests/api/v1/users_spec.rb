require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users' do
    get 'Retrieves a list of users' do
      tags 'Users'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number for pagination'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Number of users per page'

      response '200', 'users found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   data: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string, example: 'users' },
                       attributes: {
                         type: :object,
                         properties: {
                           email: { type: :string },
                           firstName: { type: :string },
                           lastName: { type: :string }
                         }
                       }
                     }
                   }
                 }
               }

        let(:users) { create_list(:user, 3) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: users.first.id, scopes: 'read') }
        let(:Authorization) { "Bearer #{access_token.token}" }

        before { users }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.length).to eq(3)
          expect(data.first['data']['type']).to eq('users')
          expect(data.first['data']['attributes']).to include('email', 'firstName', 'lastName')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end

    post 'Creates a new user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' },
              first_name: { type: :string, example: 'John' },
              last_name: { type: :string, example: 'Doe' }
            },
            required: ['email', 'password', 'password_confirmation']
          }
        }
      }

      response '201', 'user created' do
        let(:user) { { user: { email: 'test@example.com', password: 'password123', password_confirmation: 'password123', first_name: 'Test', last_name: 'User' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user']['email']).to eq('test@example.com')
          expect(data['user']['id']).to be_present
        end
      end

      response '422', 'invalid request' do
        let(:user) { { user: { email: 'invalid-email' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to be_present
        end
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true, description: 'User ID'

    get 'Retrieves a specific user' do
      tags 'Users'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'user found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string, example: 'users' },
                     attributes: {
                       type: :object,
                       properties: {
                         email: { type: :string },
                         firstName: { type: :string },
                         lastName: { type: :string }
                       }
                     }
                   }
                 }
               }

        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { user.id }

        before { user }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_present
          expect(data['data']['type']).to eq('users')
          expect(data['data']['attributes']).to include('email', 'firstName', 'lastName')
        end
      end

      response '404', 'user not found' do
        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { 'invalid' }

        before { user }

        run_test!
      end
    end

    put 'Updates a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              first_name: { type: :string, example: 'Updated Name' },
              last_name: { type: :string, example: 'Updated Last Name' }
            }
          }
        }
      }

      response '200', 'user updated' do
        let(:user_record) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user_record.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { user_record.id }
        let(:user) { { user: { first_name: 'Updated Name' } } }

        before { user_record }

        run_test! do |response|
          data = JSON.parse(response.body)
          # Check if response has data structure or direct user structure
          if data['data']
            expect(data['data']).to be_present
            expect(data['data']['type']).to eq('users')
            expect(data['data']['attributes']['firstName']).to eq('Updated Name')
          else
            expect(data['user']).to be_present
            expect(data['user']['first_name']).to eq('Updated Name')
          end
        end
      end

      response '404', 'user not found' do
        let(:user_record) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user_record.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { 'invalid' }
        let(:user) { { user: { first_name: 'Updated Name' } } }

        before { user_record }

        run_test!
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      produces 'application/json'
      security [bearerAuth: []]

      response '204', 'user deleted' do
        let(:user_record) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user_record.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { user_record.id }

        before { user_record }

        run_test!
      end

      response '404', 'user not found' do
        let(:user_record) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user_record.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { 'invalid' }

        run_test!
      end
    end
  end
end
