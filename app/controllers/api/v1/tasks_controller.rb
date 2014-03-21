class Api::V1::TasksController < Api::V1::BaseController
  caches :index, caches_for: 5.minutes
  before_filter :find_project
  before_filter :find_task, only: [:show, :update, :destroy]

  def index
    expose @project.tasks.paginate(page: params[:page])
  end

  def show
    expose @task
  end

  def create
    task = @project.tasks.create(create_params)
    expose task
  end

  def update
    @task.update(update_params)
    expose @task
  end

  def destroy
    @task.destroy
  end

private

  def create_params
    params.require(:task).permit!
  end

  def update_params
    params.require(:task).permit(:name,:description)
  end

  def find_project
    @project = current_user.projects.find(params[:project_id])
  end

  def find_task
    @task = @project.tasks.find(params[:id])
  end

end
