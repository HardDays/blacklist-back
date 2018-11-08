class EmployeesController < ApplicationController
  before_action :auth_and_set_employee, only: [:create, :update]
  before_action :set_employee, only: [:show]
  swagger_controller :employee, "Employees"

  # GET /employees
  swagger_api :index do
    summary "Retrieve employees list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    employees = Employee.all

    render json: employees.limit(params[:limit]).offset(params[:offset]), short: true, status: :ok
  end

  # GET /employees/1
  swagger_api :show do
    summary "Get employee profile"
    param :path, :id, :integer, :required, "User id"
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
  def set_employee
    begin
      @employee = Employee.find(params[:id])
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

  def employee_params
    params.permit(:first_name, :last_name, :second_name, :birthday, :gender, :education,
                  :education_year, :contacts, :skills, :experience, :status, :position)
  end
end

