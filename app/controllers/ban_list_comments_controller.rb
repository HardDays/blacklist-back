class BanListCommentsController < ApplicationController
  before_action :auth_payed_user, only: [:index, :create]
  before_action :set_ban_list, only: [:index, :create]
  swagger_controller :ban_list_comments, "Black list comments"

  # GET /ban_lists_comments
  swagger_api :index do
    summary "Retrieve ban list comments"
    param :path, :black_list_id, :integer, :required, "Black list id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
  end
  def index
    @comments = @ban_list.ban_list_comments.all

    render json: {
      count: BanListComment.count,
      items: @comments.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # POST /ban_lists_comments
  swagger_api :create do
    summary "Create new comment"
    param :path, :black_list_id, :integer, :required, "Black list id"
    param_list :form, :comment_type, :string, :required, "Type of comment", [:like, :dislike]
    param :form, :text, :string, :required, "Text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
  end
  def create
    @comment = BanListComment.new(ban_list_comment_params)
    @comment.user_id = @user.id
    @comment.ban_list_id = @ban_list.id

    if @comment.save
      render json: @comment, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private
  def set_ban_list
    begin
      @ban_list = BanList.find(params[:black_list_id])

      unless @ban_list.status == "approved"
        render status: :not_found
      end
    rescue
      render status: :not_found
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def auth_payed_user
    @user = AuthorizationHelper.auth_user_with_payment_without_id(request)

    unless @user
      render status: :forbidden and return
    end

    payments = @user.payments.where(
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
    def ban_list_comment_params
      params.permit(:comment_type, :text)
    end
end
