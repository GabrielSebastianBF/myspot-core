# frozen_string_literal: true

require 'net/http'
require 'json'

class OllamaService
  def self.embed(text)
    uri = URI("http://localhost:11434/api/embeddings")
    model = ENV.fetch('OLLAMA_EMBED_MODEL', 'nomic-embed-text')
    
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = { model: model, prompt: text }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)['embedding']
    else
      Rails.logger.error "Ollama Embedding Error: #{response.body}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Ollama Connection Error: #{e.message}"
    nil
  end
end
