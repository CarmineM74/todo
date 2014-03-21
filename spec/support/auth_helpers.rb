module AuthHelpers

  def login_as(user)
    u = User.find_by_name(user[:name])
    success = u.authenticate(user[:password])
    if success
      u.ensure_auth_token
      u.save
      request.headers['Authorization'] = "Token #{u.auth_token}"
    else
      logout
    end
  end

  def logout(user)
    request.headers['Authorization'] = ""
    user.auth_token = nil
    user.save
  end

end
