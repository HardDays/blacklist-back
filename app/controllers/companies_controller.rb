class CompaniesController < ApplicationController
  before_action :authorize_user, only: [:show, :create, :update]
  before_action :set_company, only: [:show, :update]
  swagger_controller :company, "Companies"

  # GET /companies/1
  swagger_api :show do
    summary "Get company profile"
    param :path, :id, :integer, :required, "User id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
  end
  def show
    render json: @company, status: :ok
  end

  # POST /companies
  swagger_api :create do
    summary "Create company profile"
    param :form, :id, :integer, :required, "User id"
    param :form, :name, :string, :required, "Company name"
    param :form, :description, :string, :optional, "Company description"
    param :form, :contacts, :string, :optional, "Company contacts"
    param :form, :address, :string, :optional, "Company address"
    param :form, :kitchen, :string, :optional, "Company kitchen"
    param :form, :work_time, :string, :optional, "Company work time"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unprocessable_entity
  end
  def create
    company = Company.new(company_params)
    company.user_id = @user.id

    if company.save
      render json: company, status: :ok
    else
      render json: company.errors, status: :unprocessable_entity
    end
  end

  # PATCH /companies/1
  swagger_api :update do
    summary "Update company profile"
    param :path, :id, :integer, :required, "User id"
    param :form, :name, :string, :optional, "Company name"
    param :form, :description, :string, :optional, "Company description"
    param :form, :contacts, :string, :optional, "Company contacts"
    param :form, :address, :string, :optional, "Company address"
    param :form, :work_time, :string, :optional, "Company work time"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def update
    if @company.update(company_params)
      render json: @company, status: :ok
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  protected
  def set_company
    @company = @user.company

    unless @company
      render status: :not_found and return
    end
  end

  def authorize_user
    @user = AuthorizationHelper.auth_user(request, params[:id])

    unless @user
      render status: :forbidden and return
    end
  end

  def company_params
    params.permit(:name, :description, :contacts, :address, :kitchen, :work_time)
  end
end
