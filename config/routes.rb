Todo::Application.routes.draw do

  api versions: 1, module: 'api/v1' do
    resource :session, only: [:create, :destroy]
    resources :users, except: [:index, :new, :edit, :destroy]
    resources :projects, only: [:index, :create, :update, :destroy] do
      resources :tasks
    end
  end
end
