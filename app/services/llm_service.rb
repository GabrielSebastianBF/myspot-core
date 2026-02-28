class LlmService
  require 'net/http'
  require 'json'
  
  MODEL = ENV.fetch('LLM_MODEL', 'minimax/MiniMax-M2.5')
  API_URL = "https://openrouter.ai/api/v1/chat/completions"
  
  def self.api_key
    ENV['OPENROUTER_API_KEY']
  end
  
  def self.chat(messages, agent: nil)
    return { content: "API key no configurada. Ve a Settings y configura tu OpenRouter API Key." } unless api_key.present?
    
    system_prompt = agent&.config&.dig("system_prompt") || default_system_prompt
    
    full_messages = [
      { role: "system", content: system_prompt },
      *messages
    ]
    
    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    request["HTTP-Referer"] = "http://localhost:3000"
    request["X-Title"] = "MySpot"
    
    body = {
      model: MODEL,
      messages: full_messages,
      temperature: agent&.config&.dig("temperature") || 0.7,
      max_tokens: agent&.config&.dig("max_tokens") || 4096
    }
    
    request.body = body.to_json
    
    begin
      response = http.request(request)
      data = JSON.parse(response.body)
      
      if data["choices"] && data["choices"].first
        { content: data["choices"].first["message"]["content"] }
      else
        { content: "Error: #{data['error'] || 'Respuesta inválida'}" }
      end
    rescue => e
      { content: "Error de conexión: #{e.message}" }
    end
  end
  
  def self.default_system_prompt
    <<~PROMPT
      Eres Spot, el asistente personal de Gabriel (Lemut) en ITLab.
      Eres leal, proactivo y técnicamente riguroso.
      Tu personalidad:
      - Profesional pero cálido
      - Proactivo en proponer soluciones
      - Técnicamente preciso
      - Sigues el protocolo HITL (Human-In-The-Loop) para decisiones críticas
      - Usas emojis ocasionalmente 🐕
    PROMPT
  end
end
