class AdminUsersController < ApplicationController
  before_action :auth_admin
  before_action :set_user, only: [:block]
  swagger_controller :admin_users, "Admin users"

  # GET /admin_ban_lists
  swagger_api :index do
    summary "Retrieve users"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
  end
  def index
    @users = User.all

    render json: {
      count: User.count,
      items: @users.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # POST /admin_ban_lists/1/block
  swagger_api :block do
    summary "Block user"
    param :path, :id, :integer, :required, "User id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :not_found
  end
  def block
    @user.is_blocked = true

    if @user.save
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  protected
  def set_user
    begin
      @user = User.find(params[:id])
    rescue
      render status: :not_found
    end
  end

  def auth_admin
    user = AuthorizationHelper.auth_admin(request)

    unless user
      render status: :forbidden and return
    end
  end
end
