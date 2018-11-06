class UsersController < ApplicationController
  swagger_controller :users, "Users"

  # GET /users/id
  swagger_api :show do
    summary "Get user info"
    param :path, :id, :integer, :required, "User id"
    response :ok
    response :not_found
  end
  def show
    user = User.find(params[:id])

    render json: user, status: :ok
  end

  # GET /users/get_by_code
  swagger_api :get_by_code do
    summary "Find user by code"
    param :form, :code, :integer, :required, "Verification code"
    response :ok
    response :not_found
  end
  def get_by_code
    user = User.find_by(confirmation_token: params[:code], password: "")
    render json: user, status: :ok
  end

  # POST /users
  swagger_api :create do
    summary "Register user"
    param :form, :email, :string, :required, "User email"
    response :ok
  end
  def create
    ActiveRecord::Base.transaction do
      token = TokenHelper.generate_register_token

      user = User.new(create_params)
      user.confirmation_token = token
      user.confirmation_sent_at = DateTime.now
      if user.save(validate: false)
        ConfirmationMailer.confirmation_email(params[:email], token).deliver

        render json: user, status: :created
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH /users/:id
  swagger_api :update do
    summary "Set user password"
    param :path, :id, :integer, :required, "User id"
    param :form, :email, :string, :required, "User email"
    param :form, :code, :integer, :required, "Verification code"
    param :form, :password, :string, :required, "User password"
    param :form, :password_confirmation, :string, :required, "User password confirm"
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def update
    user = User.find(params[:id])

    if user.email == params[:email] and user.confirmation_token == params[:code]
      if user.update(update_params)
        user.update(confirmed_at: DateTime.now)
        render json: user, status: :ok
      else
        render json: user.errors, status: :unprocessable_entity
      end
    else
      render json: {errors: INVALID_CODE}, status: :forbidden
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  protected
  def create_params
    params.permit(:email)
  end

  def update_params
    params.permit(:password, :password_confirmation)
  end
end
