class SecurityFilesController < ApplicationController
  before_action :auth_admin, only: [:create]
  before_action :set_security_file, only: [:show]
  swagger_controller :security_file, "Security file"


  # GET /security_files/1
  swagger_api :show do
    summary "Get security file"
    param :path, :id, :integer, :required, "id"
    response :not_found
  end
  def show
    render json: {"base64": @security_file.base64 }, status: :ok
    # send_data Base64.decode64(@security_file.base64.gsub(/^data:image\/[a-z]+;base64,/, '')), :type => 'image/png', :disposition => 'inline'
  end

  # POST /security_files
  swagger_api :create do
    summary "Upload file template"
    param :form, :base64, :string, :required, "Image base64 string"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def create
    SecurityFile.delete_all

    @security_file = SecurityFile.new(base64: params[:base64])
    if @security_file.save
      render json: @security_file, status: :ok
    else
      render json: @security_file.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_security_file
      begin
        @security_file = SecurityFile.first

        unless @security_file
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
end
