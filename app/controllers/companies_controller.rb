class CompaniesController < ApplicationController
  before_action :authorize_user, only: [:show, :create, :update]
  before_action :set_company, only: [:show, :update]
  before_action :check_user, only: [:show, :update]
  swagger_controller :company, "Companies"

  # GET /companies/1
  swagger_api :show do
    summary "Get company profile"
    param :path, :id, :integer, :required, "Company id"
    param :query, :user_id, :integer, :required, "User id"
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
    param :form, :user_id, :integer, :required, "User id"
    param :form, :name, :string, :required, "Company name"
    param :form, :description, :string, :optional, "Company description"
    param :form, :contacts, :string, :optional, "Company contacts"
    param :form, :address, :string, :optional, "Company address"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
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
    param :path, :id, :integer, :required, "Company id"
    param :form, :user_id, :integer, :required, "User id"
    param :form, :name, :string, :required, "Company name"
    param :form, :description, :string, :optional, "Company description"
    param :form, :contacts, :string, :optional, "Company contacts"
    param :form, :address, :string, :optional, "Company address"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
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
    begin
      @company = Company.find(params[:id])
    rescue
      render status: :not_found
    end
  end

  def authorize_user
    @user = AuthorizationHelper.auth_user(request, params[:id])

    unless @user
      render status: :forbidden and return
    end
  end

  def check_user
    unless @user.id == @company.user_id
      render status: :forbidden and return
    end
  end

  def company_params
    params.permit(:name, :description, :contacts, :address)
  end
end
