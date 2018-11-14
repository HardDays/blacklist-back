class ConfirmationMailer < ApplicationMailer
  layout 'mailer'

  def confirmation_email(email, token)
    @token = token
    mail(from:'mousereminder@gmail.com', to: email, subject: "Подтверждение регистрации")
  end
end