class ChatController < ApplicationController
  before_action :set_agent

  def index
    @sessions = @agent.sessions.order(created_at: :desc).limit(50)
  end

  private

  def set_agent
    # Por defecto, usar el agente Spot
    @agent = Agent.find_by(name: 'Spot') || Agent.first
  end
end
