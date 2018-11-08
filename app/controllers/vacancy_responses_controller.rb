class VacancyResponsesController < ApplicationController
  before_action :auth_and_set_user, only: [:index, :create]
  before_action :check_company, only: [:index]
  before_action :set_vacancy, only: [:index, :create]
  before_action :set_employee, only: [:create]
  before_action :check_employee, only: [:create]
  swagger_controller :vacancy_response, "Vacancy responces"

  # GET /vacancy_responses
  swagger_api :index do
    summary "Retrieve list of responses"
    param :path, :vacancy_id, :integer, :required, "Vacancy_id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :not_found
  end
  def index
    @vacancy_responses = VacancyResponse.all

    render json: @vacancy_responses.limit(params[:limit]).offset(params[:offset]), status: :ok
  end

  # POST /vacancy_responses
  swagger_api :index do
    summary "Create vacancy response"
    param :path, :vacancy_id, :integer, :required, "Vacancy_id"
    param :form, :employee_id, :integer, :required, "Employee id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :not_found
  end
  def create
    @vacancy_response = VacancyResponse.new(vacancy_response_params)

    if @vacancy_response.save
      render json: @vacancy_response, status: :ok
    else
      render json: @vacancy_response.errors, status: :unprocessable_entity
    end
  end

  private
  def auth_and_set_user
    @user = AuthorizationHelper.auth_and_set_user(request)

    unless @user
      render status: :forbidden and return
    end
  end

  def set_vacancy
    begin
      @vacancy = Vacancy.find(params[:vacancy_id])
    rescue
        render status: :not_found and return
    end
  end

  def check_company
    unless @vacancy.company.user_id == @user.id
      render status: :forbidden and return
    end
  end

  def set_employee
    begin
      @employee = Employee.find(params[:employee_id])
    rescue
      render status: :not_found and return
    end
  end

  def check_employee
    unless @employee.user_id == @user.id
      render status: :forbidden and return
    end
  end

  def vacancy_response_params
    params.permit(:vacancy_id, :employee_id)
  end
end
