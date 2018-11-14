class ForgotPasswordMailer < ApplicationMailer
  layout 'mailer'

  def forgot_password_email(email, password)
    @password = password
    mail(from:'mousereminder@gmail.com', to: email, subject: "Восстановление пароля")
  end
end