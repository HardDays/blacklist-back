class BanListsController < ApplicationController
  before_action :auth_payed_user, only: [:index, :create]
  swagger_controller :ban_list, "Black list"

  # GET /ban_lists
  swagger_api :index do
    summary "Retrieve ban list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @ban_lists = BanList.all

    render json: @ban_lists.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # POST /ban_lists
  swagger_api :create do
    summary "Create new note in ban list"
    param :form, :name, :string, :required, "Name"
    param :form, :description, :string, :required, "Description/Position"
    param :form, :addresses, :string, :optional, "Work addresses/Addresses"
    response :ok
    response :forbidden
  end
  def create
    @ban_list = BanList.new(ban_list_params)

    if @ban_list.save
      render json: @ban_list, status: :ok
    else
      render json: @ban_list.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def auth_payed_user
      user = AuthorizationHelper.auth_payed_user_without_id(request)

      unless user
        render status: :forbidden and return
      end
    end

    # Only allow a trusted parameter "white list" through.
    def ban_list_params
      params.permit(:name, :description, :addresses)
    end
end
