class DashboardController < ApplicationController
  #before_action :require_login
  def index
    @agents = Agent.all
    @sessions_today = Session.where("created_at >= ?", Date.today).count
    @memories_count = Memory.count
    @pending_executions = ToolExecution.where(status: 'pending').count
    
    # Stats del día
    @sessions_week = Session.where("created_at >= ?", 7.days.ago).count
  end
end
