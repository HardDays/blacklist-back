class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  before_save :encrypt
  validates_confirmation_of :password, message: 'NOT_MATCHED', if: :password_changed?
  attr_accessor :password_confirmation

  SALT = 'elite_salt'

  def self.encrypt_password(password)
    return Digest::SHA256.hexdigest(password + SALT)
  end

  def encrypt
    self.password = User.encrypt_password(self.password) if self.password
  end
end
