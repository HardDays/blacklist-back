class EmployeeOffersController < ApplicationController
  before_action :auth_payed_user, only: [:index, :show, :create]
  before_action :auth_employee, only: [:index, :show]
  before_action :set_offer, only: [:show]
  before_action :set_company, only: [:create]
  before_action :set_employee, only: [:create]
  swagger_controller :employee_offers, "Employee offer"

  # GET /employees/1/employee_offers
  swagger_api :index do
    summary "Retrieve list of offers"
    param :path, :employee_id, :integer, :required, "Employee id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, "Authorization token"
    response :ok
    response :forbidden
  end
  def index
    @employee_offers = @employee.employee_offers.all

    render json: {
      count: @employee.employee_offers.count,
      items: @employee_offers.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # GET /employees/1/employee_offers/1
  swagger_api :show do
    summary "Retrieve offer info"
    param :path, :employee_id, :integer, :required, "Employee id"
    param :path, :id, :integer, :required, "Offer id"
    param :header, 'Authorization', :string, :required, "Authorization token"
    response :ok
    response :not_found
    response :forbidden
  end
  def show
    render json: @employee_offer, status: :ok
  end

  # POST /employees/1/employee_offers
  swagger_api :create do
    summary "Make offer to employee"
    param :path, :id, :integer, :required, "Employee id"
    param :form, :position, :string, :required, "Position to offer"
    param :form, :description, :string, :optional, "Description"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def create
    offer = EmployeeOffer.new(employee_offer_params)
    offer.employee_id = @employee.id
    offer.company_id = @company.id

    if offer.save
      render json: offer, status: :ok
    else
      render json: offer.errors, status: :unprocessable_entity
    end
  end

  private
  def set_offer
    begin
      @employee_offer = @employee.employee_offers.find(params[:id])
    rescue
        render status: :not_found
    end
  end

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

  def auth_employee
    unless @user.id == params[:employee_id].to_i
      render status: :forbidden and return
    end

    @employee = @user.employee

    unless @employee
      render status: :forbidden and return
    end
  end

  def set_company
    @company = @user.company

    unless @company
      render status: :forbidden and return
    end
  end

  def set_employee
    begin
      user = User.find(params[:employee_id])
      @employee = user.employee

      unless @employee
        render status: :not_found and return
      end
    rescue
      render status: :not_found and return
    end
  end

  def employee_offer_params
    params.permit(:position, :description)
  end
end
