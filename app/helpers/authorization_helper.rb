module AuthorizationHelper

  def self.auth_user(request, user_id)
    tokenstr = request.headers['Authorization']

    token = Token.find_by(token: tokenstr)
    if token and token.user_id == user_id.to_i
      return token.user
    end
  end

  def self.auth_user_without_id(request)
    tokenstr = request.headers['Authorization']

    token = Token.find_by(token: tokenstr)
    if token
      return token.user
    end
  end

end