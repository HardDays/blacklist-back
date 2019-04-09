class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, if: :confirmed_at?

  before_save :encrypt
  validates_confirmation_of :password, message: 'NOT_MATCHED', if: :password_changed?
  attr_accessor :password_confirmation

  belongs_to :image, dependent: :destroy, optional: true
  has_one :company, dependent: :destroy
  has_one :employee, dependent: :destroy
  has_many :tokens, dependent: :destroy
  has_many :forgot_password_attempts, dependent: :destroy
  has_many :ban_list_comments, dependent: :destroy
  has_many :employee_comments, dependent: :destroy
  has_many :security_requests, dependent: :destroy
  has_many :payments, dependent: :destroy

  SALT = 'elite_salt'

  def self.encrypt_password(password)
    return Digest::SHA256.hexdigest(password + SALT)
  end

  def encrypt
    if password_changed?
      if self.password and self.password != ""
        self.password = User.encrypt_password(self.password) if self.password
      end
    end
  end

  def as_json(options={})
    if options[:only]
      return res
    end

    res = super
    res.delete('password')
    res.delete('reset_password_token')
    res.delete('reset_password_sent_at')
    res.delete('confirmation_token')
    res.delete('confirmed_at')
    res.delete('confirmation_sent_at')

    if employee
      res[:user_type] = 'employee'
      res[:name] = employee.first_name
    elsif company
      res[:user_type] = 'company'
      res[:name] = company.name
    end

    if payments.count > 0
      res[:is_payed] = true

      valid_payments = payments.where(
          payment_type: [Payment.payment_types['standard'], Payment.payment_types['economy']],
          status: 'ok'
      ).where(
          "(expires_at >= :query)", query: DateTime.now
      )
      if valid_payments.count > 0
        res[:is_payed_everything] = true
        res[:is_payed_employee_list] = true
        res[:is_payed_employee_search] = true
      else
        res[:is_payed_everything] = false
      end

      valid_payments = payments.where(
          payment_type: [Payment.payment_types['vacancies_5'], Payment.payment_types['vacancies_4']],
          status: 'ok'
      )
      if valid_payments.count > 0
        res[:is_payed_vacancies] = true
      else
        res[:is_payed_vacancies] = false
      end

      valid_payments = payments.where(
          payment_type: [Payment.payment_types['employee_list_week'], Payment.payment_types['employee_list_month']],
          status: 'ok'
      ).where(
          "(expires_at >= :query)", query: DateTime.now
      )
      if valid_payments.count > 0
        res[:is_payed_employee_list] = true
      else
        res[:is_payed_employee_list] = false
      end

      valid_payments = payments.where(
          payment_type: Payment.payment_types['security_file'],
          status: 'ok'
      )
      if valid_payments.count > 0
        res[:is_payed_security] = true
      else
        res[:is_payed_security] = false
      end

      valid_payments = payments.where(
          payment_type: Payment.payment_types['employee_search'],
          status: 'ok'
      ).where(
          "(expires_at >= :query)", query: DateTime.now
      )
      if valid_payments.count > 0
        res[:is_payed_employee_list] = true
        res[:is_payed_employee_search] = true
      else
        res[:is_payed_employee_search] = false
      end
    else
      res[:is_payed] = false
    end

    if is_admin
      res[:is_payed] = true
      res[:is_payed_everything] = true
      res[:is_payed_employee_list] = true
      res[:is_payed_employee_search] = true
      res[:is_payed_vacancies] = true
    end

    res
  end
end
