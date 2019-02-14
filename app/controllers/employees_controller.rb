class EmployeesController < ApplicationController
  before_action :auth_payed_user, only: [:index]
  before_action :auth_and_set_employee, only: [:create, :update]
  before_action :auth_user_and_set_employee, only: [:show]
  swagger_controller :employee, "Employees"

  # GET /employees
  swagger_api :index do
    summary "Retrieve employees list"
    param :query, :text, :string, :optional, "Text to search"
    param :query, :position, :string, :optional, "Position text to search"
    param :query, :experience, :integer, :optional, "Experience to search"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
  end
  def index
    @employees = Employee.approved

    if @is_filters_available
      search_text
      search_position
      search_experience
    end

    render json: {
      count: Employee.approved.count,
      items: @employees.limit(params[:limit]).offset(params[:offset])
    }, short: true, status: :ok
  end

  # GET /employees/dashboard
  swagger_api :dashboard do
    summary "Retrieve last five employees"
    response :ok
  end
  def dashboard
    @employees = Employee.approved

    render json: @employees.limit(5), short: true, status: :ok
  end

  # GET /employees/1
  swagger_api :show do
    summary "Get employee profile"
    param :path, :id, :integer, :required, "User id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
  end
  def show
    render json: @employee, status: :ok
  end

  # POST /employees
  swagger_api :create do
    summary "Create employee profile"
    param :form, :id, :integer, :required, "User id"
    param :form, :first_name, :string, :required, "First name"
    param :form, :last_name, :string, :required, "Last name"
    param :form, :second_name, :string, :required, "Second name"
    param :form, :birthday, :string, :optional, "Birthday"
    param_list :form, :gender, :string, :optional, "Gender", [:m, :f]
    param :form, :education, :string, :optional, "Education"
    param :form, :education_year, :integer, :optional, "Education finish year"
    param :form, :contacts, :string, :optional, "Contacts"
    param :form, :skills, :string, :optional, "Skills"
    param :form, :experience, :string, :optional, "Experience"
    param_list :form, :status, :string, :optional, "Status", [:draft, :posted]
    param :form, :position, :string, :optional, "Position"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def create
    employee = Employee.new(employee_params)
    employee.user_id = @user.id

    if employee.save
      render json: employee, status: :ok
    else
      render json: employee.errors, status: :unprocessable_entity
    end
  end

  # PATCH /employees/1
  swagger_api :update do
    summary "Update employee profile"
    param :path, :id, :integer, :required, "User id"
    param :form, :first_name, :string, :optional, "First name"
    param :form, :last_name, :string, :optional, "Last name"
    param :form, :second_name, :string, :optional, "Second name"
    param :form, :birthday, :string, :optional, "Birthday"
    param_list :form, :gender, :string, :optional, "Gender", [:m, :f]
    param :form, :education, :string, :optional, "Education"
    param :form, :education_year, :integer, :optional, "Education finish year"
    param :form, :contacts, :string, :optional, "Contacts"
    param :form, :skills, :string, :optional, "Skills"
    param :form, :experience, :string, :optional, "Experience"
    param_list :form, :status, :string, :optional, "Status", [:draft, :posted]
    param :form, :position, :string, :optional, "Position"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def update
    if @employee.update(employee_params)
      render json: @employee, status: :ok
    else
      render json: @employee.errors, status: :unprocessable_entity
    end
  end

  protected
  def auth_user_and_set_employee
    begin
      @user = AuthorizationHelper.auth_user_without_id(request)

      if @user == nil
        render status: :forbidden and return
      elsif @user.id == params[:id].to_i
        @employee = @user.employee
      else
        list_payments = @user.payments.where(
            payment_type: [Payment.payment_types['employee_list_week'], Payment.payment_types['employee_list_month'],
                           Payment.payment_types['employee_search'], Payment.payment_types['standard'],
                           Payment.payment_types['economy']],
            status: 'ok'
        ).where(
            "(expires_at >= :query)", query: DateTime.now
        )

        if list_payments.count == 0
          render status: :forbidden and return
        end

        user = User.find(params[:id])
        @employee = user.employee

        if @employee.status != "approved"
          render status: :not_found and return
        end
      end
    rescue
      render status: :not_found
    end
  end

  def auth_and_set_employee
    @user = AuthorizationHelper.auth_user(request, params[:id])

    unless @user
      render status: :forbidden and return
    end

    @employee = @user.employee
  end

  def auth_payed_user
    @is_filters_available = false
    @user = AuthorizationHelper.auth_user_with_payment_without_id(request)

    unless @user
      render status: :forbidden and return
    end

    # если оплачен пакет, то можно все
    payments = @user.payments.where(
        payment_type: [Payment.payment_types['standard'], Payment.payment_types['economy'],
                       Payment.payment_types['employee_search']],
        status: 'ok'
    ).where(
        "(expires_at >= :query)", query: DateTime.now
    )
    if payments.count == 0
        list_payments = @user.payments.where(
            payment_type: [Payment.payment_types['employee_list_week'], Payment.payment_types['employee_list_month']],
            status: 'ok'
        ).where(
            "(expires_at >= :query)", query: DateTime.now
        )

        if list_payments.count == 0
          render status: :forbidden and return
        end
    else
      @is_filters_available = true
    end
  end

  def search_text
    if params[:text]
      @employees = @employees.where("(first_name ILIKE :query OR second_name ILIKE :query OR last_name ILIKE :query)",
                                    query: "%#{params[:text]}%")
    end
  end

  def search_position
    if params[:position]
      @employees = @employees.where("(position ILIKE :query)", query: "%#{params[:position]}%")
    end
  end

  def search_experience
    if params[:experience]
      @employees = @employees.where("(experience >= :query)", query: params[:experience])
    end
  end

  def employee_params
    params.permit(:first_name, :last_name, :second_name, :birthday, :gender, :education,
                  :education_year, :contacts, :skills, :experience, :status, :position)
  end
end

