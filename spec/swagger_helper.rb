require 'rails_helper'

# Configure RSwag
RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  config.openapi_specs = {
    'v1/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Rails API Template V1',
        version: 'v1',
        description: 'API for managing football/soccer data including teams, players, matches, and more.',
        contact: {
          name: 'API Support',
          email: 'support@rails-api-template.com'
        },
        license: {
          name: 'MIT',
          url: 'https://opensource.org/licenses/MIT'
        }
      },
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.rails-api-template.com',
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'OAuth 2.0 Bearer Token from Doorkeeper'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              email: { type: :string, example: 'user@example.com' },
              first_name: { type: :string, example: 'John' },
              last_name: { type: :string, example: 'Doe' },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['email', 'first_name', 'last_name']
          },
          Team: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'Barcelona FC' },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['name']
          },
          Player: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              first_name: { type: :string, example: 'Lionel' },
              last_name: { type: :string, example: 'Messi' },
              email: { type: :string, example: 'messi@example.com' },
              team_id: { type: :integer, example: 1 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['first_name', 'last_name', 'email']
          },
          Match: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              home_team_id: { type: :integer, example: 1 },
              away_team_id: { type: :integer, example: 2 },
              date: { type: :string, format: 'date', example: '2024-01-15' },
              home_score: { type: :integer, example: 2 },
              away_score: { type: :integer, example: 1 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['home_team_id', 'away_team_id', 'date']
          },
          Goal: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              match_id: { type: :integer, example: 1 },
              player_id: { type: :integer, example: 1 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['match_id', 'player_id']
          },
          Card: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              match_id: { type: :integer, example: 1 },
              player_id: { type: :integer, example: 1 },
              card_type: { type: :string, example: 'yellow', enum: ['yellow', 'red'] },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['match_id', 'player_id', 'card_type']
          },
          Assist: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              match_id: { type: :integer, example: 1 },
              player_id: { type: :integer, example: 1 },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['match_id', 'player_id']
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Error message' },
              details: { type: :object, additionalProperties: true }
            }
          },
          OAuthApplication: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'My OAuth App' },
              uid: { type: :string, example: 'abc123def456' },
              secret: { type: :string, example: 'xyz789uvw012' },
              redirect_uri: { type: :string, example: 'https://myapp.com/callback' },
              scopes: { type: :string, example: 'read write' },
              confidential: { type: :boolean, example: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['name', 'redirect_uri']
          }
        }
      },
      tags: [
        { name: 'Users', description: 'User management operations' },
        { name: 'Teams', description: 'Team management operations' },
        { name: 'Players', description: 'Player management operations' },
        { name: 'Matches', description: 'Match management operations' },
        { name: 'Goals', description: 'Goal management operations' },
        { name: 'Cards', description: 'Card management operations' },
        { name: 'Assists', description: 'Assist management operations' },
        { name: 'Authentication', description: 'Authentication operations' },
        { name: 'OAuth Applications', description: 'OAuth application management operations' }
      ]
    }
  }

  # Set the format that documents are generated in
  config.openapi_format = :json
end
