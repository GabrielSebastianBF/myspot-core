class Api::AgentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:chat]
  before_action :authenticate_agent!, except: [:create, :index]
  
  require_relative '../../services/llm_service'
  require_relative '../../services/ollama_service'

  def index
    agents = Agent.all
    render json: agents
  end

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
    message_content = params.require(:message)
    channel = params[:channel] || 'web'
    
    # Usar sesión activa o crear nueva
    session = current_agent.sessions.where(channel: channel, ended_at: nil).order(created_at: :desc).first
    session ||= current_agent.sessions.create!(channel: channel, started_at: Time.current)
    
    # Guardar mensaje del usuario
    user_message = session.messages.create!(role: 'user', content: message_content)
    
    # Obtener historial de mensajes para contexto
    history = session.messages.order(created_at: :asc).last(10).map do |m|
      { role: m.role, content: m.content }
    end
    
    # Buscar memorias relevantes (si Ollama está disponible)
    context_memories = ""
    if OllamaService.available?
      relevant_memories = OllamaService.similar_memories(current_agent.id, message_content, 3)
      if relevant_memories.any?
        context_memories = "\n\nInformación relevante de la memoria:\n"
        relevant_memories.each do |mem|
          context_memories += "- [#{mem.memory_type}] #{mem.content}\n"
        end
      end
    end
    
    # Agregar contexto de memorias al último mensaje del usuario si hay
    if context_memories.present? && history.any?
      history.last[:content] += context_memories
    end
    
    # Generar respuesta con LLM
    response = LlmService.chat(history, agent: current_agent)
    response_content = response[:content]
    
    # Guardar respuesta del asistente
    assistant_message = session.messages.create!(role: 'assistant', content: response_content)
    
    # Auto-guardar en memorias si es importante (opcional)
    # Memory.create!(agent: current_agent, session: session, content: message_content, memory_type: 'short', importance: 1) if message_content.length > 100
    
    render json: {
      session_id: session.id,
      user_message: user_message,
      assistant_message: assistant_message,
      status: 'completed'
    }
  end

  def session_messages
    session = current_agent.sessions.find(params[:id])
    messages = session.messages.order(created_at: :asc)
    render json: messages
  end

  private

  def agent_params
    params.require(:agent).permit(:name, :config, :model_preferred, :role)
  end
end
