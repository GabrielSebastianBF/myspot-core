class Api::ToolExecutionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_agent!

  def index
    executions = ToolExecution
      .joins(:session)
      .where(sessions: { agent_id: current_agent.id })
      .order(created_at: :desc)
      .limit(100)
    
    render json: executions
  end

  def show
    execution = ToolExecution.find(params[:id])
    render json: execution
  end

  # Aprobar ejecución (HITL)
  def approve
    execution = ToolExecution.find(params[:id])
    
    unless execution.requires_approval?
      render json: { error: 'Execution already processed' }, status: :unprocessable_entity
      return
    end

    execution.update!(
      approved_by: current_agent.id,
      status: 'approved'
    )

    # Ejecutar
    result = execute_tool(execution)

    render json: { 
      execution_id: execution.id, 
      status: 'executed', 
      result: result 
    }
  end

  # Rechazar ejecución (HITL)
  def reject
    execution = ToolExecution.find(params[:id])
    
    execution.update!(
      approved_by: current_agent.id,
      status: 'rejected'
    )

    render json: { 
      execution_id: execution.id, 
      status: 'rejected' 
    }
  end

  private

  def execute_tool(execution)
    # Por ahora retornamos un resultado simulado
    {
      success: true,
      message: "Herramienta #{execution.tool_name} ejecutada",
      output: "Demo output for #{execution.tool_name}"
    }
  end
end
