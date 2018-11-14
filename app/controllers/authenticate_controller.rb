class AuthenticateController < ApplicationController
  swagger_controller :auth, "Authentication"

  # POST /auth/login
  swagger_api :login do
    summary "Authorize by email and password"
    param :form, :email, :string, :required, "Email"
    param :form, :password, :password, :required, "Password"
    response :forbidden
  end
  def login
    password = User.encrypt_password(params[:password])
    user = User.find_by("LOWER(email) = ?", params[:email].downcase)

    unless user
      render status: :forbidden and return
    end

    if user.password != password
      render status: :forbidden and return
    end

    token = TokenHelper.process_token(request, user)
    user = user.as_json
    user["token"] = token
    render json: user , status: :ok
  end

  # POST /auth/logout
  swagger_api :logout do
    summary "Logout"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :bad_request
  end
  def logout
    token = Token.find_by(token: request.headers['Authorization'])
    if token
      token.destroy
      render status: :ok
    else
      render status: :bad_request
    end
  end

  # POST /auth/forgot_password
  swagger_api :forgot_password do
    summary "Remind password"
    param :form, :email, :string, :optional, "Email"
    response :ok
    response :bad_request
    response :unauthorized
  end
  def forgot_password
    user = User.find_by("LOWER(email) = ?", params[:email].downcase)
    unless user
      render json: {error: :USER_DOES_NOT_EXIST}, status: :unauthorized and return
    end

    attempt = ForgotPasswordAttempt.where(
      user_id: user.id, created_at: (Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)).first
    if attempt
      if attempt.attempt_count >=3
        render json: {error: :TOO_MANY_ATTEMPTS}, status: :bad_request and return
      end

      attempt.attempt_count += 1
      attempt.save
    else
      attempt = ForgotPasswordAttempt.new(user_id: user.id, attempt_count: 1)
      attempt.save
    end

    password = SecureRandom.hex(4)
    user.password = password
    begin
      ForgotPasswordMailer.forgot_password_email(params[:email], password).deliver

      user.save(validate: false)
      render status: :ok
    rescue => ex
      render status: :bad_request
    end
  end
end
