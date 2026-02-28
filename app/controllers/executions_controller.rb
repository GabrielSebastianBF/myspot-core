class ExecutionsController < ApplicationController
  #before_action :require_login
  def index
    @executions = ToolExecution.order(created_at: :desc).limit(50)
  end
end
