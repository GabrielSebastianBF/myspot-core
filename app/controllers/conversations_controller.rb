class ConversationsController < ApplicationController
  #before_action :require_login
  
  def index
    @sessions = Session.order(created_at: :desc).limit(50)
  end

  def show
    @session = Session.find(params[:id])
    @messages = @session.messages.order(created_at: :asc)
  end
end
