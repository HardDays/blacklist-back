module AuthorizationHelper

  def self.auth_user(request, user_id)
    tokenstr = request.headers['Authorization']

    token = Token.find_by(token: tokenstr)
    if token and token.user_id == user_id.to_i and !token.user.is_blocked
      return token.user
    end
  end

  def self.auth_user_without_id(request)
    tokenstr = request.headers['Authorization']

    token = Token.find_by(token: tokenstr)
    if token and !token.user.is_blocked
      return token.user
    end
  end

  def self.auth_payed_user_without_id(request)
    tokenstr = request.headers['Authorization']

    token = Token.find_by(token: tokenstr)
    if (token&.user&.is_payed and !token.user.is_blocked) or token&.user&.is_admin
      return token.user
    end
  end

  def self.auth_admin(request)
    tokenstr = request.headers['Authorization']

    token = Token.find_by(token: tokenstr)
    if token&.user&.is_admin
      return token.user
    end
  end

end