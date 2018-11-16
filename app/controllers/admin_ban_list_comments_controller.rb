class AdminBanListCommentsController < ApplicationController
  before_action :auth_admin
  before_action :set_ban_list_comment
  swagger_controller :admin_ban_list_comment, "Admin black list comments"

  # DELETE /admin_ban_list_comments/1
  swagger_api :destroy do
    summary "Delete comment"
    param :path, :id, :integer, :required, "Item id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def destroy
    @comment.destroy

    render status: :ok
  end

  protected
  def set_ban_list_comment
    begin
      @comment = BanListComment.find(params[:id])
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
