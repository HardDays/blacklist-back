class AdminEmployeesController < ApplicationController
  before_action :auth_admin
  before_action :set_employee, only: [:show, :approve, :deny]
  swagger_controller :admin_employees, "Admin employees"

  # GET /admin_employees
  swagger_api :index do
    summary "Retrieve employees"
    param_list :query, :status, :string, :optional, "Status", [:added, :approved, :denied]
    param :query, :text, :string, :optional, "Text to search"
    param :query, :position, :string, :optional, "Position text to search"
    param :query, :experience, :integer, :optional, "Experience to search"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
  end
  def index
    @employees = Employee.all

    if params[:status]
      @employees = @employees.where(status: Employee.statuses[params[:status]])
    end
    search_text
    search_position
    search_experience

    render json: {
      count: Employee.count,
      items: @employees.limit(params[:limit]).offset(params[:offset])
    }, short: true, status: :ok
  end

  # GET /admin_employees/1
  swagger_api :show do
    summary "Retrieve employee info"
    param :path, :id, :integer, :required, "Employee id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :not_found
  end
  def show
    render json: @employee, status: :ok
  end

  # POST /admin_employees/1/approve
  swagger_api :approve do
    summary "Approve employee"
    param :path, :id, :integer, :required, "Employee id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :not_found
  end
  def approve
    @employee.status = "approved"

    if @employee.save
      render json: @employee, status: :ok
    else
      render json: @employee.errors, status: :unprocessable_entity
    end
  end

  # POST /admin_employees/1/deny
  swagger_api :deny do
    summary "Deny employees"
    param :form, :id, :integer, :required, "Employee id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def deny
    @employee.status = "denied"

    if @employee.save
      render json: @employee, status: :ok
    else
      render json: @employee.errors, status: :unprocessable_entity
    end
  end

  protected
  def set_employee
    begin
      user = User.find(params[:id])

      @employee = user.employee
      unless @employee
        render status: :not_found
      end
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
end
