Rails.application.routes.draw do
  namespace :api do
    resources :agents do
      member do
        get :memories
        post :chat
      end
    end
    
    resources :tools do
      member do
        post :execute
        post :approve
        post :reject
      end
      collection do
        get :executions
      end
    end
    
    resources :sessions do
      member do
        get :executions
      end
    end
    
    post '/tools/executions/:execution_id/approve', to: 'tools#approve'
    post '/tools/executions/:execution_id/reject', to: 'tools#reject'
  end

  # WebSocket
  mount ActionCable.server => '/cable'
  
  # UI Routes
  get '/dashboard', to: 'dashboard#index'
  get '/chat', to: 'chat#index'
  get '/agents', to: 'agents#index'
  get '/memories', to: 'memories#index'
  get '/tools', to: 'tools#index'
  get '/executions', to: 'executions#index'
  get '/settings', to: 'settings#index'
  get '/', to: 'dashboard#index'
end
