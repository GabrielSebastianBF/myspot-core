class ApplicationController < ActionController::Base
  helper_method :current_user, :current_agent, :user_signed_in?
  
  private

  # Autenticación de usuario (para UI)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def user_signed_in?
    current_user.present?
  end
  
  def require_login
    unless user_signed_in?
      redirect_to login_path, alert: 'Debes iniciar sesión.'
    end
  end

  # Autenticación de agente (para API)
  def current_agent
    @current_agent ||= Agent.find_by(id: session[:agent_id]) if session[:agent_id]
    @current_agent ||= Agent.find_by(id: request.headers['X-Agent-Id']) if request.headers['X-Agent-Id']
    @current_agent ||= Agent.first if request.path.start_with?('/api')
    @current_agent
  end

  def authenticate_agent!
    unless current_agent
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
