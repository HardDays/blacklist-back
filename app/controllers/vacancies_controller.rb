class VacanciesController < ApplicationController
  before_action :authorize_user, only: [:create, :update]
  before_action :set_company, only: [:create, :update]
  before_action :set_vacancy, only: [:update]
  before_action :auth_user_without_id, only: [:index, :show]
  swagger_controller :vacancy, "Vacancy"

  # GET /vacancies
  swagger_api :index do
    summary "Retrieve all vacancies"
    param :query, :text, :string, :optional, "Text to search"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def index
    @vacancies = Vacancy.all
    search_text

    render json: @vacancies.limit(params[:limit]).offset(params[:offset]), short: true, status: :ok
  end

  # GET /vacancies/1
  swagger_api :show do
    summary "Retrieve vacancy info"
    param :path, :id, :integer, :required, "Vacancy id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
  end
  def show
    begin
      vacancy = Vacancy.find(params[:id])
      render json: vacancy, status: :ok
    rescue
        render status: :not_found
    end
  end

  # POST /employees
  swagger_api :create do
    summary "Create company vacancy"
    param :path, :company_id, :integer, :required, "User id"
    param :form, :position, :string, :required, "Position"
    param :form, :min_experience, :integer, :optional, "Minimal experience needed"
    param :form, :salary, :string, :optional, "Salary"
    param :form, :description, :string, :required, "Description"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :unprocessable_entity
  end
  def create
    vacancy = Vacancy.new(vacancy_params)
    vacancy.company_id = @company.id

    if vacancy.save
      render json: vacancy, status: :ok
    else
      render json: vacancy.errors, status: :unprocessable_entity
    end
  end

  # PATCH /employees/1
  swagger_api :update do
    summary "Update company vacancy"
    param :path, :company_id, :integer, :required, "User id"
    param :path, :id, :integer, :required, "Vacancy id"
    param :form, :position, :string, :optional, "Position"
    param :form, :min_experience, :integer, :optional, "Minimal experience needed"
    param :form, :salary, :string, :optional, "Salary"
    param :form, :description, :string, :optional, "Description"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
  end
  def update
    if @vacancy.update(vacancy_params)
      render json: @vacancy, status: :ok
    else
      render json: @vacancy.errors, status: :unprocessable_entity
    end
  end

  protected
  def set_company
    @company = @user.company

    unless @company
      render status: :not_found
    end
  end

  def set_vacancy
    begin
      @vacancy = @company.vacancies.find(params[:id])
    rescue
      render status: :not_found
    end
  end

  def authorize_user
    @user = AuthorizationHelper.auth_user(request, params[:company_id])

    unless @user
      render status: :forbidden and return
    end
  end

  def auth_user_without_id
    user = AuthorizationHelper.auth_user_without_id(request)

    unless user
      render status: :forbidden and return
    end
  end


  def search_text
    if params[:text]
      @vacancies = @vacancies.where("position ILIKE ?", "%#{params[:text]}%")
    end
  end

  def vacancy_params
    params.permit(:position, :min_experience, :salary, :description)
  end
end
