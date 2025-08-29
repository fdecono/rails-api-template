require 'rails_helper'

RSpec.describe UserSerializer, type: :serializer do
  let(:user) { create(:user) }
  let(:serializer) { described_class.new(user) }
  let(:user_serialization) { JSON.parse(serializer.to_json) }

  it 'renders the user correctly' do
    expect(user_serialization).to eq(
      "email" => user.email,
      "first_name" => user.first_name,
      "last_name" => user.last_name
    )
  end
end
