class AgentChannel < ApplicationCable::Channel
  # Channel para comunicación en tiempo real con el agente
  
  def subscribed
    # El usuario se conecta a su agente
    agent_id = params[:agent_id]
    @agent = Agent.find(agent_id)
    
    stream_from "agent_#{agent_id}"
    puts "📡 User subscribed to agent #{@agent.name}"
  end

  def unsubscribed
    puts "📴 User unsubscribed"
  end

  def chat(data)
    message = data['message']
    session = @agent.sessions.create!(
      channel: 'web',
      started_at: Time.current,
      metadata: { source: 'websocket' }
    )

    # Enviar a OpenClaw Lite
    openclaw = OpenClawService.new(
      agent_id: @agent.id,
      session_id: session.id
    )

    # Obtener contexto de memorias
    memory_service = MemoryService.new(agent: @agent)
    context = memory_service.get_context_for_prompt

    # Enviar mensaje
    response = openclaw.send_message(message, context: context)
    
    # Guardar en memoria
    memory_service.store(
      "User: #{message}",
      memory_type: :short,
      session: session
    )
    
    if response['message']
      memory_service.store(
        "Agent: #{response['message']}",
        memory_type: :short,
        session: session
      )
    end

    # Transmitir respuesta al cliente
    ActionCable.server.broadcast(
      "agent_#{@agent.id}",
      {
        session_id: session.id,
        message: response['message'],
        status: response['status']
      }
    )
  end

  def tool_request(data)
    tool_name = data['tool']
    args = data['args'] || {}
    
    session = @agent.sessions.last
    
    # Crear registro de ejecución
    execution = ToolExecution.create!(
      session: session,
      tool_name: tool_name,
      args: args,
      status: 'pending'
    )

    # Verificar si requiere aprobación humana
    tool = Tool.find_by(name: tool_name)
    
    if tool && !tool.can_execute?(@agent.role)
      execution.update!(status: 'rejected')
      transmit({ error: 'Tool not allowed for this role' })
      return
    end

    # Ejecutar
    openclaw = OpenClawService.new(
      agent_id: @agent.id,
      session_id: session.id
    )
    
    result = openclaw.execute_tool(tool_name, args)
    
    execution.update!(
      result: result,
      status: 'executed'
    )

    transmit({ 
      tool: tool_name, 
      result: result,
      execution_id: execution.id
    })
  end
end
