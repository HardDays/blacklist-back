class ImagesController < ApplicationController
  before_action :authorize_user, only: [:create, :destroy]
  before_action :auth_user_without_id, only: [:show, :get_with_size]
  swagger_controller :images, "Images"

  swagger_api :show do
    summary "Get full image"
    param :path, :id, :integer, :required, "Image id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
  end
  def show
    begin
      image = Image.find(params[:id])
    rescue
      render status: :not_found and return
    end

    send_data Base64.decode64(image.base64.gsub(/^data:image\/[a-z]+;base64,/, '')), :type => 'image/png', :disposition => 'inline'
  end

  swagger_api :get_with_size do
    summary "Get full image with size"
    param :path, :id, :integer, :required, "Image id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :not_found
  end
  def get_with_size
    begin
      image = Image.find(params[:id])
    rescue
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
    ActiveRecord::Base.transaction do
      image = Image.new(base64: params[:base64])
      if image.save
        @user.image = image
        @user.save!

        render json: image, status: :ok
      else
        render json: image.errors, status: :unprocessable_entity
      end
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
    begin
      image = Image.find(params[:id])
    rescue
      render status: :not_found and return
    end

    if @user.image_id == image.id
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

  def auth_user_without_id
    user = AuthorizationHelper.auth_user_without_id(request)

    if user == nil
      render status: :forbidden and return
    end
  end

end
