require 'swagger_helper'

RSpec.describe 'OAuth Applications API', type: :request do
  path '/api/v1/oauth_applications' do
    get 'Retrieves a list of OAuth applications' do
      tags 'OAuth Applications'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'applications found' do
        schema type: :object,
               properties: {
                 applications: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       uid: { type: :string },
                       secret: { type: :string },
                       redirect_uri: { type: :string },
                       scopes: { type: :string },
                       confidential: { type: :boolean },
                       created_at: { type: :string, format: 'date-time' },
                       updated_at: { type: :string, format: 'date-time' }
                     }
                   }
                 }
               }

                let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read') }
        let(:Authorization) { "Bearer #{access_token.token}" }

        before { user }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['applications']).to be_present
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end

    post 'Creates a new OAuth application' do
      tags 'OAuth Applications'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :oauth_application, in: :body, schema: {
        type: :object,
        properties: {
          oauth_application: {
            type: :object,
            properties: {
              name: { type: :string, example: 'My OAuth App' },
              redirect_uri: { type: :string, example: 'https://myapp.com/callback' },
              scopes: { type: :string, example: 'read write' }
            },
            required: ['name', 'redirect_uri']
          }
        }
      }

      response '201', 'application created' do
        schema type: :object,
               properties: {
                 application: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     uid: { type: :string },
                     secret: { type: :string },
                     redirect_uri: { type: :string },
                     scopes: { type: :string },
                     confidential: { type: :boolean },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        let(:oauth_application) do
          {
            oauth_application: {
              name: 'New OAuth App',
              redirect_uri: 'http://localhost:3000/callback',
              scopes: 'read write'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['application']['name']).to eq('New OAuth App')
          expect(data['application']['id']).to be_present
          expect(data['application']['created_at']).to be_present
        end
      end

      response '422', 'invalid request' do
        let(:oauth_application) do
          {
            oauth_application: {
              name: '', # Invalid: empty name
              redirect_uri: 'invalid-url-format'
            }
          }
        end

        run_test!
      end

      response '201', 'application created without auth' do
        let(:oauth_application) { { oauth_application: { name: 'Test', redirect_uri: 'http://localhost:3000/callback' } } }

        run_test!
      end
    end
  end

  path '/api/v1/oauth_applications/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Retrieves an OAuth application' do
      tags 'OAuth Applications'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'application found' do
        schema type: :object,
               properties: {
                 application: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     uid: { type: :string },
                     secret: { type: :string },
                     redirect_uri: { type: :string },
                     scopes: { type: :string },
                     confidential: { type: :boolean },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { create(:oauth_application).id }

        before { user }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['application']).to be_present
        end
      end

      response '404', 'application not found' do
        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { 'invalid' }

        before { user }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }

        run_test!
      end
    end

    put 'Updates an OAuth application' do
      tags 'OAuth Applications'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :oauth_application, in: :body, schema: {
        type: :object,
        properties: {
          oauth_application: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Updated OAuth App' },
              redirect_uri: { type: :string, example: 'https://updatedapp.com/callback' },
              scopes: { type: :string, example: 'read write admin' }
            }
          }
        }
      }

      response '200', 'application updated' do
        schema type: :object,
               properties: {
                 application: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     uid: { type: :string },
                     secret: { type: :string },
                     redirect_uri: { type: :string },
                     scopes: { type: :string },
                     confidential: { type: :boolean },
                     created_at: { type: :string, format: 'date-time' },
                     updated_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:oauth_app) { create(:oauth_application) }
        let(:id) { oauth_app.id }
        let(:oauth_application) do
          {
            oauth_application: {
              name: 'Updated App Name',
              scopes: 'read write admin'
            }
          }
        end

        before { user }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['application']['name']).to eq('Updated App Name')
          expect(data['application']['id']).to be_present
        end
      end

      response '422', 'invalid request' do
        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:oauth_app) { create(:oauth_application) }
        let(:id) { oauth_app.id }
        let(:oauth_application) do
          {
            oauth_application: {
              name: '', # Invalid: empty name
              redirect_uri: 'invalid-url-format'
            }
          }
        end

        before { user }

        run_test!
      end

      response '404', 'application not found' do
        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { 99999 }
        let(:oauth_application) { { oauth_application: { name: 'Test' } } }

        before { user }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }
        let(:oauth_application) { { oauth_application: { name: 'Test' } } }

        run_test!
      end
    end

    delete 'Deletes an OAuth application' do
      tags 'OAuth Applications'
      security [bearerAuth: []]

      response '204', 'application deleted' do
        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:oauth_app) { create(:oauth_application) }
        let(:id) { oauth_app.id }

        before { user }

        run_test!
      end

      response '404', 'application not found' do
        let(:user) { create(:user) }
        let(:application) { create(:oauth_application) }
        let(:access_token) { Doorkeeper::AccessToken.create!(application: application, resource_owner_id: user.id, scopes: 'read write') }
        let(:Authorization) { "Bearer #{access_token.token}" }
        let(:id) { 99999 }

        before { user }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }

        run_test!
      end
    end
  end
end
