class NewsController < ApplicationController
  before_action :auth_admin, only: [:create, :update, :destroy]
  before_action :set_news, only: [:show, :update, :destroy]
  swagger_controller :news, "News"

  # GET /news
  swagger_api :index do
    summary "Retrieve news list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @news = News.all

    render json: {
        count: News.count,
        items: @news.limit(params[:limit]).offset(params[:offset])
    }, short: true, status: :ok
  end

  # GET /news/1
  swagger_api :show do
    summary "Get news by id"
    param :path, :id, :integer, :required, "User id"
    response :ok
    response :not_found
  end
  def show
    render json: @news, status: :ok
  end

  # POST /news
  swagger_api :create do
    summary "Delete news"
    param :form, :text, :string, :required, "New Text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def create
    @news = News.new(news_params)

    if @news.save
      render json: @news, status: :ok
    else
      render json: @news.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /news/1
  swagger_api :update do
    summary "Delete news"
    param :path, :id, :integer, :required, "Item id"
    param :form, :text, :string, :required, "New Text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def update
    if @news.update(news_params)
      render json: @news, status: :ok
    else
      render json: @news.errors, status: :unprocessable_entity
    end
  end

  # DELETE /news/1
  swagger_api :destroy do
      summary "Delete news"
      param :path, :id, :integer, :required, "Item id"
      param :header, 'Authorization', :string, :required, 'Authentication token'
      response :ok
      response :not_found
      response :forbidden
      response :unprocessable_entity
  end
  def destroy
    @news.destroy

    render status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_news
      begin
        @news = News.find(params[:id])
      rescue
        render status: :not_found
      end
    end

    # Only allow a trusted parameter "white list" through.
    def news_params
      params.permit(:text)
    end

  def auth_admin
    user = AuthorizationHelper.auth_admin(request)

    unless user
      render status: :forbidden and return
    end
  end
end
