class ApplicationController < ActionController::Base
  # Helper methods para autenticación básica
  helper_method :current_agent

  private

  def current_agent
    @current_agent ||= Agent.find_by(id: session[:agent_id]) if session[:agent_id]
  end

  def authenticate_agent!
    unless current_agent
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
