class AuthenticateController < ApplicationController
  swagger_controller :auth, "Authentication"

  # POST /auth/login
  swagger_api :login do
    summary "Authorize by email and password"
    param :form, :email, :string, :optional, "Email"
    param :form, :password, :password, :required, "Password"
    response :unauthorized
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
    render json: {token: token.token} , status: :ok

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
end
