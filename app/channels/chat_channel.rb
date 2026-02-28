class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:agent_id]}"
  end

  def unsubscribed
    stop_all_streams
  end

  def chat(data)
    message = data['message']
    agent_id = data['agent_id']
    
    # Buscar o crear sesión
    agent = Agent.find(agent_id)
    session = agent.sessions.where(channel: 'websocket', ended_at: nil).last
    
    unless session
      session = agent.sessions.create!(channel: 'websocket', started_at: Time.current)
    end
    
    # Guardar mensaje del usuario
    user_msg = session.messages.create!(role: 'user', content: message)
    
    # Obtener historial
    history = session.messages.order(created_at: :asc).last(10).map do |m|
      { role: m.role, content: m.content }
    end
    
    # Generar respuesta
    response = LlmService.chat(history, agent: agent)
    
    # Guardar respuesta
    assistant_msg = session.messages.create!(role: 'assistant', content: response[:content])
    
    # Broadcast al cliente
    ActionCable.server.broadcast(
      "chat_#{agent_id}",
      {
        type: 'message',
        user_message: {
          role: 'user',
          content: user_msg.content,
          created_at: user_msg.created_at
        },
        assistant_message: {
          role: 'assistant',
          content: assistant_msg.content,
          created_at: assistant_msg.created_at
        }
      }
    )
  end
end
