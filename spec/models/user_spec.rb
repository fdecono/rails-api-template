require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }

    it 'validates uniqueness of email case-insensitively' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'TEST@EXAMPLE.COM')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe 'password validations' do
    context 'when creating a new user' do
      let(:user) { build(:user, password: nil) }

      it 'requires password' do
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end
    end

    context 'when updating an existing user' do
      let(:user) { create(:user) }

      it 'does not require password if unchanged' do
        user.first_name = 'New Name'
        expect(user).to be_valid
      end
    end
  end

  describe 'attributes' do
    it 'has admin defaulting to false' do
      user = User.new
      expect(user.admin).to be false
    end

    it 'has confirmed_at defaulting to nil' do
      user = User.new
      expect(user.confirmed_at).to be_nil
    end
  end

  describe 'instance methods' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Doe') }

    describe '#full_name' do
      it 'returns the full name' do
        expect(user.full_name).to eq('John Doe')
      end
    end

    describe '#admin?' do
      context 'when user is admin' do
        let(:user) { build(:user, admin: true) }

        it 'returns true' do
          expect(user.admin?).to be true
        end
      end

      context 'when user is not admin' do
        let(:user) { build(:user, admin: false) }

        it 'returns false' do
          expect(user.admin?).to be false
        end
      end
    end

    describe '#confirmed?' do
      context 'when user is confirmed' do
        let(:user) { build(:user, confirmed_at: Time.current) }

        it 'returns true' do
          expect(user.confirmed?).to be true
        end
      end

      context 'when user is not confirmed' do
        let(:user) { build(:user, confirmed_at: nil) }

        it 'returns false' do
          expect(user.confirmed?).to be false
        end
      end
    end
  end

  describe 'class methods' do
    describe '.authenticate' do
      let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

      context 'with valid credentials' do
        it 'returns the user' do
          # Debug: check if user was created properly
          expect(user).to be_persisted
          expect(user.password_digest).to be_present

          authenticated_user = User.authenticate('test@example.com', 'password123')
          expect(authenticated_user).to eq(user)
        end
      end

      context 'with invalid email' do
        it 'returns nil' do
          authenticated_user = User.authenticate('wrong@example.com', 'password123')
          expect(authenticated_user).to be nil
        end
      end

      context 'with invalid password' do
        it 'returns nil' do
          authenticated_user = User.authenticate('test@example.com', 'wrongpassword')
          expect(authenticated_user).to be nil
        end
      end
    end
  end

  describe 'private methods' do
    let(:user) { build(:user) }

    describe '#password_required?' do
      context 'when creating a new user' do
        it 'returns true' do
          expect(user.send(:password_required?)).to be true
        end
      end

      context 'when updating with password' do
        let(:user) { create(:user) }

        it 'returns true when password is present' do
          user.password = 'newpassword'
          expect(user.send(:password_required?)).to be true
        end
      end
    end

    describe '#password_confirmation_required?' do
      context 'when password confirmation is present' do
        it 'returns true' do
          user.password_confirmation = 'password123'
          expect(user.send(:password_confirmation_required?)).to be true
        end
      end

      context 'when password confirmation is not present' do
        it 'returns false' do
          user.password_confirmation = nil
          expect(user.send(:password_confirmation_required?)).to be false
        end
      end
    end
  end
end
