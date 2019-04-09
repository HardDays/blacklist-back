class AdminVacanciesController < ApplicationController
  before_action :auth_admin
  before_action :set_vacancy, only: [:show, :approve, :deny]
  swagger_controller :admin_vacancies, "Admin vacancies"

  # GET /admin_vacancies
  swagger_api :index do
    summary "Retrieve vacancies"
    param_list :query, :status, :string, :optional, "Status", [:added, :approved, :denied]
    param :query, :text, :string, :optional, "Text to search"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
  end
  def index
    @vacancies = Vacancy.all

    if params[:status]
      @vacancies = @vacancies.where(status: Vacancy.statuses[params[:status]])
    end
    search_text

    render json: {
      count: Vacancy.count,
      items: @vacancies.order(id: :desc).limit(params[:limit]).offset(params[:offset])
    }, short: true, status: :ok
  end

  # GET /admin_vacancies/1
  swagger_api :show do
    summary "Retrieve vacancy info"
    param :path, :id, :integer, :required, "Vacancy id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :not_found
  end
  def show
    render json: @vacancy, status: :ok
  end

  # POST /admin_vacancies/1/approve
  swagger_api :approve do
    summary "Approve vacancy"
    param :path, :id, :integer, :required, "Vacancy id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :not_found
  end
  def approve
    @vacancy.status = "approved"

    if @vacancy.save
      render json: @vacancy, status: :ok
    else
      render json: @vacancy.errors, status: :unprocessable_entity
    end
  end

  # POST /admin_vacancies/1/deny
  swagger_api :deny do
    summary "Deny vacancies"
    param :form, :id, :integer, :required, "Vacancy id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def deny
    @vacancy.status = "denied"

    if @vacancy.save
      render json: @vacancy, status: :ok
    else
      render json: @vacancy.errors, status: :unprocessable_entity
    end
  end

  protected
  def set_vacancy
    begin
      @vacancy = Vacancy.find(params[:id])
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

  def search_text
    if params[:text]
      @vacancies = @vacancies.where("position ILIKE ?", "%#{params[:text]}%")
    end
  end
end
