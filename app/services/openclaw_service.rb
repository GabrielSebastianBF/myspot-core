# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

class OpenClawService
  # Cliente para comunicarse con OpenClaw Lite
  
  BASE_URL = ENV.fetch('OPENCLAW_URL', 'http://localhost:3001')
  API_KEY = ENV.fetch('OPENCLAW_API_KEY', '')

  def initialize(agent_id:, session_id:)
    @agent_id = agent_id
    @session_id = session_id
    @uri = URI.parse(BASE_URL)
  end

  # Enviar mensaje al agente
  def send_message(content, context: nil)
    payload = {
      agent_id: @agent_id,
      session_id: @session_id,
      message: content,
      context: context,
      tools: allowed_tools
    }

    post('/api/agent/chat', payload)
  end

  # Ejecutar una herramienta específica
  def execute_tool(tool_name, args = {})
    payload = {
      tool: tool_name,
      args: args,
      session_id: @session_id
    }

    post('/api/tools/execute', payload)
  end

  # Obtener estado del Gateway
  def status
    get('/api/status')
  end

  # Listar herramientas disponibles
  def list_tools
    get('/api/tools')
  end

  private

  def allowed_tools
    # Obtener herramientas permitidas desde la base de datos
    Tool.where(enabled: true).pluck(:name)
  end

  def get(path)
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = @uri.scheme == 'https'
    
    request = Net::HTTP::Get.new(path)
    request['Authorization'] = "Bearer #{API_KEY}"
    request['Content-Type'] = 'application/json'
    
    response = http.request(request)
    JSON.parse(response.body) if response.body
  end

  def post(path, payload)
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = @uri.scheme == 'https'
    
    request = Net::HTTP::Post.new(path)
    request['Authorization'] = "Bearer #{API_KEY}"
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    
    response = http.request(request)
    JSON.parse(response.body) if response.body
  end
end
