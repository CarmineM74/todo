class Api::V1::ProjectsController < Api::V1::BaseController
  caches :index, caches_for: 5.minutes
  before_filter :find_project, only: [:update, :destroy]

  def index
    expose current_user.projects.paginate(page: params[:page])
  end

  def create
    project = current_user.projects.create!(create_params)
    expose project
  end

  def update
    @project.update!(update_params)
    expose @project
  end

  def destroy
    @project.destroy
  end

private

  def create_params
    params.require(:project).permit!
  end

  def update_params
    params.require(:project).permit(:title,:description)
  end

  def find_project
    @project = current_user.projects.find(params[:id])
  end

end
