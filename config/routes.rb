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
      end
    end
    
    resources :sessions do
      member do
        get : executions
      end
    end
  end

  # WebSocket route para ActionCable
  mount ActionCable.server => '/cable'
  
  # Dashboard (placeholder)
  get '/dashboard', to: 'dashboard#index'
  get '/', to: 'dashboard#index'
end
