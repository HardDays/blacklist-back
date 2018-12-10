class EmployeeCommentsController < ApplicationController
  before_action :auth_payed_user, only: [:index, :create]
  before_action :set_employee, only: [:index, :create]
  swagger_controller :employee_comments, "Employee comments"

  # GET /employee_comments
  swagger_api :index do
    summary "Retrieve employee comments"
    param :path, :employee_id, :integer, :required, "Employee id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
  end
  def index
    @comments = @employee_user.employee_comments.all

    render json: {
      count: EmployeeComment.count,
      items: @comments.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # POST /employee_comments
  swagger_api :create do
    summary "Create new comment"
    param :path, :employee_id, :integer, :required, "Black list id"
    param_list :form, :comment_type, :string, :required, "Type of comment", [:like, :dislike]
    param :form, :text, :string, :required, "Text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
  end
  def create
    @comment = EmployeeComment.new(employee_comments_params)
    @comment.user_id = @user.id

    if @comment.save
      render json: @comment, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private
  def set_employee
    begin
      @employee_user = User.find(params[:employee_id])
      employee = @employee_user.employee

      unless employee&.status == "approved"
        render status: :not_found
      end
    rescue
      render status: :not_found
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def auth_payed_user
    @user = AuthorizationHelper.auth_payed_user_without_id(request)

    unless @user
      render status: :forbidden and return
    end
  end

  # Only allow a trusted parameter "white list" through.
  def employee_comments_params
    params.permit(:comment_type, :text)
  end
end
