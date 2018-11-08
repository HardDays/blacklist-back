class UsersController < ApplicationController
  before_action :authorize_user, only: [:update]
  before_action :auth_and_set_user, only: [:my]
  before_action :set_user, only: [:show]
  swagger_controller :users, "Users"

  # GET /users/id
  swagger_api :show do
    summary "Get user info"
    param :path, :id, :integer, :required, "User id"
    response :ok
    response :not_found
  end
  def show
    if @user
      render json: @user, status: :ok
    else
      render status: :not_found
    end
  end

  # GET /users/my
  swagger_api :my do
    summary "Get user info"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
  end
  def my
    if @user
      render json: @user, status: :ok
    else
      render status: :not_found
    end
  end

  # POST /users/verify_code
  swagger_api :verify_code do
    summary "Verify user code"
    param :form, :code, :string, :required, "Verification code"
    param :form, :email, :string, :required, "Email"
    response :ok
    response :not_found
  end
  def verify_code
    user = User.find_by(confirmation_token: params[:code], email: params[:email])

    if user
      token = TokenHelper.process_token(request, user)
      user = user.as_json
      user[:token] = token

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
    param :form, :password, :string, :required, "User password"
    param :form, :password_confirmation, :string, :required, "User password confirm"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def update
    user = User.find(params[:id])

    ActiveRecord::Base.transaction do
      if user
        user.confirmed_at = DateTime.now
        user.password = params[:password]
        user.password_confirmation = params[:password_confirmation]

        if user.save
          token = TokenHelper.process_token(request, user)
          user = user.as_json
          user[:token] = token

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
  def set_user
    begin
      @user = User.find(params[:id])
    rescue
        render status: :not_found and return
    end
  end

  def create_params
    params.permit(:email)
  end

  def authorize_user
    @user = AuthorizationHelper.auth_user(request, params[:id])

    unless @user
      render status: :forbidden and return
    end
  end

  def auth_and_set_user
    @user = AuthorizationHelper.auth_and_set_user(request)

    unless @user
      render status: :forbidden and return
    end
  end
end
