class Api::V1::BaseController < RocketPants::Base
  version 1
  jsonp

  before_filter :verify_authorization

  def current_user
    @current_user || nil
  end

  def logout_current_user
    current_user.clear_auth_token! if current_user
  end

protected

  def verify_authorization
    @current_user = nil
    Rails.logger.info "Attempting authentication from token ..."
    authenticate_with_http_token do |token, options|
      Rails.logger.info "Authenticating from token: #{token} - options: #{options}"
      @current_user = User.find_by_auth_token(token)
      Rails.logger.info "No authenticated user found" unless @current_user
      Rails.logger.info "User AUTHENTICATED: #{@current_user.name}" if @current_user
    end
    error! :unauthenticated unless @current_user
  end

end
