class Api::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_agent!

  def index
    sessions = current_agent.sessions.order(created_at: :desc).limit(50)
    render json: sessions
  end

  def show
    session = current_agent.sessions.find(params[:id])
    render json: session
  end

  def messages
    session = current_agent.sessions.find(params[:id])
    messages = session.messages.order(created_at: :asc)
    render json: messages
  end
end
