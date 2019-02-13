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

  def self.auth_user_with_payment_without_id(request)
    tokenstr = request.headers['Authorization']

    token = Token.find_by(token: tokenstr)
    if token&.user&.is_admin
      return token.user
    elsif token and !token.user&.is_blocked
      payments = token.user.payments
      if payments
        return token.user
      end
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