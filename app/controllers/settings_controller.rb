class SettingsController < ApplicationController
  #before_action :require_login
  def index
    @agent = Agent.first
  end

  def update
    # Guardar configuración en variables de entorno o base de datos
    if params[:api_key].present?
      # Guardar en session por ahora (en prod usar DB segura)
      session[:openrouter_api_key] = params[:api_key]
      ENV['OPENROUTER_API_KEY'] = params[:api_key]
    end
    
    redirect_to settings_path, notice: 'Configuración guardada.'
  end
end
