class Api::AgentsController < ApplicationController
  before_action :authenticate_agent!, except: [:create]

  def create
    agent = Agent.create!(agent_params)
    render json: { id: agent.id, name: agent.name }, status: :created
  end

  def show
    render json: current_agent
  end

  def update
    current_agent.update!(agent_params)
    render json: current_agent
  end

  def memories
    memories = current_agent.memories.order(created_at: :desc).limit(100)
    render json: memories
  end

  def chat
    # Aquí irá la lógica de chat con OpenClaw Lite
    message = params.require(:message)
    session = current_agent.sessions.create!(
      channel: params[:channel] || 'web',
      started_at: Time.current
    )

    # TODO: Integrar con WebSocket de OpenClaw Lite
    render json: {
      session_id: session.id,
      message: "Message received: #{message}",
      status: 'processing'
    }
  end

  private

  def agent_params
    params.require(:agent).permit(:name, :config, :model_preferred, :role)
  end
end
