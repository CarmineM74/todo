class Api::V1::SessionsController < Api::V1::BaseController

  skip_before_filter :verify_authorization, only: [:create]

  def create
    user = User.find_by_name(create_params[:name])
    error! :unauthenticated unless user.authenticate(create_params[:password])
    user.ensure_auth_token
    user.save
    expose user
  end

  def destroy
    logout_current_user
  end

private

  def create_params
    params.require(:user).permit(:name, :password)
  end

end
