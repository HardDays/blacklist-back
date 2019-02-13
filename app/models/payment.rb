class Payment < ApplicationRecord
  validates_presence_of :payment_type
  validates_presence_of :user_id

  belongs_to :user

  enum status: [:added, :ok]
  enum payment_type: [:employee_list_week, :employee_list_month, :vacancies_4, :vacancies_5, :employee_search,
                      :standard, :economy, :banner, :security_file]

  def self.get_hash(*s)
    Digest::SHA256.hexdigest(s.join(':'))
  end

  def self.get_price(option)
    case option
    when "employee_list_week"
      1000
    when "employee_list_month"
      3000
    when "vacancies_4"
      300
    when "vacancies_5"
      250
    when "employee_search"
      500
    when "standard"
      4500
    when "economy"
      1000
    when "banner"
      2500
    when "security_file"
      500
    else
      0
    end
  end

  def calc_expiration(payment)
    case payment.payment_type
    when "employee_list_week"
      1.week
    when "employee_list_month"
      1.month
    when "employee_search"
      1.day
    when "standard"
      30.days
    when "economy"
      10.days
    else
      0
    end
  end
end
