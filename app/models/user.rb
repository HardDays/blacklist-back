class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, if: :confirmed_at?

  before_save :encrypt
  validates_confirmation_of :password, message: 'NOT_MATCHED', if: :password_changed?
  attr_accessor :password_confirmation

  has_one :company, dependent: :destroy
  has_one :employee, dependent: :destroy
  has_one :image, dependent: :destroy
  has_many :tokens

  SALT = 'elite_salt'

  def self.encrypt_password(password)
    return Digest::SHA256.hexdigest(password + SALT)
  end

  def encrypt
    if self.password and self.password != ""
      self.password = User.encrypt_password(self.password) if self.password
    end
  end
end
