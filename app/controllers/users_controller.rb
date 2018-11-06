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

    if user
      render json: user, status: :ok
    else
      render status: :not_found
    end
  end

  # GET /users/get_by_code
  swagger_api :get_by_code do
    summary "Find user by code"
    param :query, :code, :string, :required, "Verification code"
    response :ok
    response :not_found
  end
  def get_by_code
    user = User.find_by(confirmation_token: params[:code], password: ["", nil])

    if user
      render json: user, status: :ok
    else
      render status: :not_found
    end
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
      if user.save
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

    ActiveRecord::Base.transaction do
      if user.email == params[:email] and user.confirmation_token == params[:code]
        user.confirmed_at = DateTime.now
        user.password = params[:password]
        user.password_confirmation = params[:password_confirmation]

        if user.save

          render json: user, status: :ok
        else
          render json: user.errors, status: :unprocessable_entity
        end
      else
        render json: {errors: [:INVALID_CODE]}, status: :forbidden
      end
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
end
