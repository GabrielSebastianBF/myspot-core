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
    
    # Endpoint para approvals masivos
    post '/tools/executions/:execution_id/approve', to: 'tools#approve'
    post '/tools/executions/:execution_id/reject', to: 'tools#reject'
  end

  # WebSocket routes para ActionCable
  mount ActionCable.server => '/cable'
  
  # Canal del agente
  # Client: ActionCable.connect('/cable', { agent_id: 'uuid' })
  
  # Dashboard (placeholder)
  get '/dashboard', to: 'dashboard#index'
  get '/', to: 'dashboard#index'
end
