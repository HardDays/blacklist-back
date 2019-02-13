class BanListsController < ApplicationController
  before_action :auth_payed_user, only: [:index, :show]
  before_action :auth_user, only: [:create]
  before_action :set_ban_list, only: [:show]
  swagger_controller :ban_list, "Black list"

  # GET /ban_lists
  swagger_api :index do
    summary "Retrieve ban list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def index
    @ban_lists = BanList.approved

    render json: {
      count: BanList.approved.count,
      items: @ban_lists.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # GET /ban_lists/:id
  swagger_api :show do
    summary "Retrieve ban list item"
    param :path, :id, :integer, :required, "Item id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def show
    render json: @ban_list, status: :ok
  end

  # POST /ban_lists
  swagger_api :create do
    summary "Create new note in ban list"
    param_list :form, :item_type, :string, :required, "Type of item", [:employee, :company]
    param :form, :name, :string, :required, "Name"
    param :form, :description, :string, :required, "Description/Position"
    param :form, :addresses, :string, :optional, "Work addresses/Addresses"
    param :form, :text, :string, :optional, "Additional text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
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
    def set_ban_list
      begin
        @ban_list = BanList.find(params[:id])

        unless @ban_list.status == "approved"
          render status: :not_found
        end
      rescue
        render status: :not_found
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def auth_user
      user = AuthorizationHelper.auth_user_without_id(request)

      unless user
        render status: :forbidden and return
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def auth_payed_user
      user = AuthorizationHelper.auth_user_with_payment_without_id(request)

      unless user
        render status: :forbidden and return
      end

      payments = user.payments.where(
          payment_type: [Payment.payment_types['standard'], Payment.payment_types['economy']],
          status: 'ok'
      ).where(
          "(expires_at >= :query)", query: DateTime.now
      )

      if payments.count == 0
        render status: :forbidden and return
      end
    end

    # Only allow a trusted parameter "white list" through.
    def ban_list_params
      params.permit(:item_type, :name, :description, :addresses, :text)
    end
end
