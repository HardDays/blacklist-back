class ImagesController < ApplicationController
  before_action :authorize_user, only: [:create, :destroy]
  swagger_controller :images, "Images"

  swagger_api :show do
    summary "Get full image"
    param :path, :id, :integer, :required, "Image id"
    response :not_found
  end
  def show
    image = Image.find(params[:id])
    unless image
      render status: :not_found and return
    end

    send_data Base64.decode64(image.base64), :type => 'image/png', :disposition => 'inline'
  end

  swagger_api :get_with_size do
    summary "Get full image with size"
    param :path, :id, :integer, :required, "Image id"
    response :not_found
  end
  def get_with_size
    image = Image.find(params[:id])
    unless image
      render status: :not_found and return
    end

    blob = Base64.decode64(image.base64.gsub(/^data:image\/[a-z]+;base64,/, ''))
    image = MiniMagick::Image.read(blob)
    hashed = {
      url: "https://blacklist-back.herokuapp.com/images/#{params[:id]}",
      width: image.width,
      height: image.height
    }
    render json: hashed
  end

  swagger_api :create do
    summary "Set user image"
    param :form, :user_id, :integer, :required, "User id"
    param :form, :base64, :string, :required, "Image base64 string"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def create
    image = Image.new(base64: params[:base64], user_id: params[:user_id])
    if image.save
      render json: image, status: :ok
    else
      render json: image.errors, status: :unprocessable_entity
    end
  end

  #DELETE /images/<id>
  swagger_api :destroy do
    summary "Delete image"
    param :path, :id, :integer, :required, "Image id"
    param :form, :user_id, :integer, :required, "User id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
  end
  def destroy
    image = Image.find(params[:id])
    unless image
      render status: :not_found and return
    end

    if image.user_id == params[:user_id]
      image.destroy
      render status: :ok
    else
      render status: :forbidden
    end
  end

  private
  def authorize_user
    @user = AuthorizationHelper.auth_user(request, params[:user_id])

    if @user == nil
      render status: :forbidden and return
    end
  end

end
