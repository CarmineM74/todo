class Api::V1::UsersController < Api::V1::BaseController
  before_filter :find_user, only: [:show, :update]
  skip_before_filter :verify_authorization, only: [:create]
  before_filter :check_user_compatibility, only: [:show, :update]

  def create
    error! :conflict if User.find_by_name(params[:user][:name])
    user = User.create(create_params)
    expose user
  end

  def show
    expose @user
  end

  def update
    @user.update!(update_params)
    expose @user
  end

private

  def create_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def update_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def find_user
    @user = User.find(params[:id])
  end

  def check_user_compatibility
    error! :unauthenticated unless @user.id == current_user.id
  end

end
