class AdminBanListsController < ApplicationController
  before_action :auth_admin
  before_action :set_ban_list, only: [:approve, :deny]
  swagger_controller :admin_ban_list, "Admin black list"

  # GET /admin_ban_lists
  swagger_api :index do
    summary "Retrieve ban list"
    param_list :query, :status, :string, :optional, "Status", [:added, :approved, :denied]
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
  end
  def index
    @ban_list = BanList.all

    if params[:status]
      @ban_list = @ban_list.where(status: BanList.statuses[params[:status]])
    end

    render json: {
      count: BanList.count,
      items: @ban_list.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # POST /admin_ban_lists/1/approve
  swagger_api :approve do
    summary "Approve ban list item"
    param :path, :id, :integer, :required, "Item id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :not_found
  end
  def approve
    @ban_list.status = "approved"

    if @ban_list.save
      render json: @ban_list, status: :ok
    else
      render json: @ban_list.errors, status: :unprocessable_entity
    end
  end

  # POST /admin_ban_lists/1/deny
  swagger_api :deny do
    summary "Deny ban list item"
    param :form, :id, :integer, :required, "Item id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def deny
    @ban_list.status = "denied"

    if @ban_list.save
      render json: @ban_list, status: :ok
    else
      render json: @ban_list.errors, status: :unprocessable_entity
    end
  end

  protected
  def set_ban_list
    begin
      @ban_list = BanList.find(params[:id])
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
