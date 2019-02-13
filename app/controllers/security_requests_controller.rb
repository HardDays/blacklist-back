class SecurityRequestsController < ApplicationController
  before_action :auth_admin, only: [:index, :show]
  before_action :auth_user, only: [:create]
  before_action :set_security_request, only: [:show]
  swagger_controller :security_request, "Security request"

  # GET /security_requests
  swagger_api :index do
    summary "Retrieve ban list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
  end
  def index
    @security_requests = SecurityRequest.all

    render json: {
        count: SecurityRequest.count,
        items: @security_requests.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # GET /security_requests/1
  swagger_api :show do
    summary "Get security file"
    param :path, :id, :integer, :required, "id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
  end
  def show
    send_data Base64.decode64(@security_request.base64.gsub(/^data:image\/[a-z]+;base64,/, '')), :type => 'image/png', :disposition => 'inline'
  end

  # POST /security_requests
  swagger_api :create do
    summary "Upload file"
    param :form, :base64, :string, :required, "Image base64 string"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def create
    ActiveRecord::Base.transaction do
      file = SecurityRequest.new(base64: params[:base64])
      file.user_id = @user.id
      if file.save
        payment = @payments.first
        payment.security_file_id = file.id
        payment.save

        render json: file, status: :ok
      else
        render json: file.errors, status: :unprocessable_entity
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_security_request
      begin
        @security_request = SecurityRequest.find(params[:id])
      rescue
        render status: :not_found
      end
    end

    # Only allow a trusted parameter "white list" through.
    def security_request_params
      params.permit(:base64)
    end


  def auth_user
    @user = AuthorizationHelper.auth_user_with_payment_without_id(request)

    if @user == nil
      render status: :forbidden and return
    end

    @payments = @user.payments.where(
        payment_type: [Payment.payment_types['security_file']],
        security_file_id: nil,
        status: 'ok'
    )

    if @payments.count == 0
      render status: :forbidden and return
    end
  end

  def auth_admin
    user = AuthorizationHelper.auth_admin(request)

    unless user
      render status: :forbidden and return
    end
  end
end
