require_relative "boot"

require "rails/all"

# Rails 8 Boot
require "active_support/core_ext/integer/time"

module MySpot
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = false
    
    # Configuración de ActionCable
    config.action_cable.mount_path = '/cable'
    config.action_cable.url = ENV.fetch('ACTION_CABLE_URL', 'ws://localhost:3000/cable')
    
    # MySpot-specific config
    config.openclaw_url = ENV.fetch('OPENCLAW_URL', 'http://localhost:3001')
    config.openclaw_api_key = ENV.fetch('OPENCLAW_API_KEY', '')
  end
end
