class JobsController < ApplicationController
  before_action :authorize_user, only: [:create, :update]
  before_action :set_employee, only: [:create, :update]
  before_action :set_job, only: [:update]
  swagger_controller :job, "Jobs"

  # POST /employees
  swagger_api :create do
    summary "Create employee jos"
    param :path, :employee_id, :integer, :required, "User id"
    param :form, :name, :string, :required, "Name"
    param :form, :period, :string, :required, "Period"
    param :form, :position, :string, :optional, "position"
    param :form, :description, :string, :optional, "Description"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :unprocessable_entity
  end
  def create
    job = Job.new(job_params)
    job.employee_id = @employee.id

    if job.save
      render json: job, status: :ok
    else
      render json: job.errors, status: :unprocessable_entity
    end
  end

  # PATCH /employees/1
  swagger_api :update do
    summary "Update employee profile"
    param :path, :employee_id, :integer, :required, "User id"
    param :path, :id, :integer, :required, "Job id"
    param :form, :name, :string, :required, "Name"
    param :form, :period, :string, :required, "Period"
    param :form, :position, :string, :optional, "position"
    param :form, :description, :string, :optional, "Description"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
  end
  def update
    if @job.update(job_params)
      render json: @job, status: :ok
    else
      render json: @job.errors, status: :unprocessable_entity
    end
  end

  protected
  def set_employee
    @employee = user.employee

    unless @employee
      render status: :not_found
    end
  end

  def set_job
    begin
      @job = @employee.jobs.find(params[:id])
    rescue
      render status: :not_found
    end
  end

  def authorize_user
    @user = AuthorizationHelper.auth_user(request, params[:employee_id])

    unless @user
      render status: :forbidden and return
    end
  end

  def job_params
    params.permit(:name, :period, :position, :description)
  end
end
