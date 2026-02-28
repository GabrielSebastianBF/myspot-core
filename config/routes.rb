Rails.application.routes.draw do
  # Auth Routes
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # UI Routes (vistas Rails)
  get '/dashboard', to: 'dashboard#index'
  get '/chat', to: 'chat#index'
  resources :agents
  get '/memories', to: 'memories#index'
  resources :memories, only: [:show, :new, :create, :edit, :update, :destroy]
  get '/tools', to: 'tools#index'
  resources :tools, only: [:show, :new, :create, :edit, :update, :destroy]
  get '/conversations', to: 'conversations#index'
  get '/conversations/:id', to: 'conversations#show'
  get '/executions', to: 'executions#index'
  get '/settings', to: 'settings#index'
  post '/settings', to: 'settings#update'
  get '/', to: 'dashboard#index'
  
  # API Routes
  namespace :api do
    resources :agents, only: [:index, :create, :show, :update] do
      member do
        get :memories
        post :chat
        get :sessions
      end
    end
    
    resources :sessions, only: [:index, :show] do
      member do
        get :messages
      end
    end
    
    resources :tools, only: [:index, :show] do
      member do
        post :execute
        get :executions
      end
    end
    
    # Endpoints para ejecutar acciones HITL directamente
    post '/executions/:id/approve', to: 'tool_executions#approve'
    post '/executions/:id/reject', to: 'tool_executions#reject'
    get '/executions', to: 'tool_executions#index'
  end
end
