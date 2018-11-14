class InvitationMailer < ApplicationMailer
  layout 'mailer'

  def invitation_email(email, token)
    @token = token
    mail(from:'mousereminder@gmail.com', to: email, subject: "Registration")
  end
end