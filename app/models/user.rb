class User < ApplicationRecord
  # Virtual attribute for password confirmation
  attr_accessor :password_confirmation

  # bcrypt integration
  has_secure_password

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_confirmation_required?
  validates_confirmation_of :password, if: :password_confirmation_required?
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Attributes
  attribute :admin, :boolean, default: false
  attribute :confirmed_at, :datetime

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    admin == true
  end

  def confirmed?
    confirmed_at.present?
  end

  # Doorkeeper integration - now uses bcrypt
  def self.authenticate(email, password)
    user = User.find_by(email: email)
    return nil unless user
    return nil unless user.authenticate(password) # bcrypt authenticate method
    user
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def password_confirmation_required?
    password_confirmation.present?
  end
end
