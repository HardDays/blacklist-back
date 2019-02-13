class VacanciesController < ApplicationController
  before_action :authorize_user_with_payment, only: [:create]
  before_action :authorize_user, only: [:update]
  before_action :set_company, only: [:update]
  before_action :set_vacancy, only: [:update]
  before_action :auth_payed_user, only: [:index]
  before_action :auth_user_and_set_vacancy, only: [:show]
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
    @vacancies = Vacancy.approved

    if @is_filters_available
      search_text
    end

    render json: {
      count: Vacancy.approved.count,
      items: @vacancies.limit(params[:limit]).offset(params[:offset])
    }, short: true, status: :ok
  end

  # GET /vacancies/dashboard
  swagger_api :dashboard do
    summary "Retrieve five last vacancies"
    response :ok
  end
  def dashboard
    @vacancies = Vacancy.approved.order(updated_at: :desc)

    render json: @vacancies.limit(5), short: true, status: :ok
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
    render json: @vacancy, status: :ok
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

  def auth_payed_user
    @is_filters_available = false
    @user = AuthorizationHelper.auth_user_with_payment_without_id(request)

    if @user == nil
      user = AuthorizationHelper.auth_user_without_id(request)

      if user == nil
        render status: :forbidden and return
      else
        @user = user
      end
    else
      payments = @user.payments.where(
          payment_type: [Payment.payment_types['standard'], Payment.payment_types['economy']]
      ).where(
          "(expires_at >= :query)", query: DateTime.now
      )

      unless payments.count == 0
        @is_filters_available = true
      end
    end
  end

  def authorize_user_with_payment
    @user = AuthorizationHelper.auth_user_with_payment_without_id(request)

    unless @user
      render status: :forbidden and return
    end

    @company = @user.company

    unless @company
      render status: :not_found
    end

    payments = @user.payments.where(
        payment_type: Payment.payment_types['vacancies_4'],
        status: 'ok'
    )

    if payments.count == 0
      payments = @user.payments.where(
          payment_type: Payment.payment_types['vacancies_5'],
          status: 'ok'
      )

      if payments.count == 0
        render status: :forbidden and return
      end
    else
      if @company.vacancies.count >= 4
        render status: :forbidden and return
      end
    end
  end

  def auth_user_and_set_vacancy
    @user = AuthorizationHelper.auth_user_without_id(request)

    if @user == nil
      render status: :forbidden and return
    end

    begin
      @vacancy = Vacancy.find(params[:id])
    rescue
      render status: :not_found and return
    end

    if @user.id == @vacancy.company.user_id
      return @vacancy
    else
      # unless @user.subscription
      #   render status: :forbidden and return
      # end
      #
      # unless @user.subscription.last_payment_date >= 1.month.ago
      #   render status: :forbidden and return
      # end

      if @vacancy.status != "approved"
        render status: :not_found and return
      end
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
