class Api::ToolsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_agent!
  before_action :find_tool, only: [:execute, :approve, :reject]

  # Listar todas las herramientas
  def index
    tools = Tool.all
    render json: tools
  end

  # Obtener herramienta específica
  def show
    render json: @tool
  end

  # Crear nueva herramienta
  def create
    tool = Tool.create!(tool_params)
    render json: tool, status: :created
  end

  # Solicitar ejecución de herramienta (puede requerir aprobación)
  def execute
    session = current_agent.sessions.last
    
    execution = ToolExecution.create!(
      session: session,
      tool_name: @tool.name,
      args: params.require(:args).permit!.to_h,
      status: 'pending'
    )

    # Verificar si el rol puede ejecutar automáticamente
    if @tool.can_execute?(current_agent.role)
      # Ejecutar directamente
      result = execute_tool_async(execution)
      render json: { 
        execution_id: execution.id, 
        status: 'executed', 
        result: result 
      }
    else
      # Requiere aprobación humana
      render json: { 
        execution_id: execution.id, 
        status: 'pending_approval',
        message: 'Waiting for human approval'
      }, status: :accepted
    end
  end

  # Aprobar ejecución (HITL)
  def approve
    execution = ToolExecution.find(params[:execution_id])
    
    unless execution.pending?
      render json: { error: 'Execution already processed' }, status: :unprocessable_entity
      return
    end

    execution.update!(
      approved_by: current_agent.id,
      status: 'approved'
    )

    # Ejecutar en background
    result = execute_tool_async(execution)

    render json: { 
      execution_id: execution.id, 
      status: 'executed', 
      result: result 
    }
  end

  # Rechazar ejecución (HITL)
  def reject
    execution = ToolExecution.find(params[:execution_id])
    
    execution.update!(
      approved_by: current_agent.id,
      status: 'rejected'
    )

    render json: { 
      execution_id: execution.id, 
      status: 'rejected' 
    }
  end

  # Ver historial de ejecuciones
  def executions
    executions = ToolExecution
      .joins(:session)
      .where(sessions: { agent_id: current_agent.id })
      .order(created_at: :desc)
      .limit(100)
    
    render json: executions
  end

  # Aprobar ejecución específica por ID
  def approve
    execution = ToolExecution.find(params[:execution_id] || params[:id])
    
    unless execution.pending?
      render json: { error: 'Execution already processed' }, status: :unprocessable_entity
      return
    end

    execution.update!(
      approved_by: current_agent.id,
      status: 'approved'
    )

    # Ejecutar en background
    result = execute_tool_async(execution)

    render json: { 
      execution_id: execution.id, 
      status: 'executed', 
      result: result 
    }
  end

  # Rechazar ejecución específica por ID
  def reject
    execution = ToolExecution.find(params[:execution_id] || params[:id])
    
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

  def find_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
    params.require(:tool).permit(:name, :description, :enabled, :allowed_roles, :schema)
  end

  def execute_tool_async(execution)
    # Por ahora ejecutamos sincrónico
    # En producción usar Sidekiq
    openclaw = OpenClawService.new(
      agent_id: current_agent.id,
      session_id: execution.session_id
    )
    
    result = openclaw.execute_tool(execution.tool_name, execution.args)
    
    execution.update!(
      result: result,
      status: 'executed'
    )
    
    result
  end
end
