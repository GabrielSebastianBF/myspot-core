class AgentsController < ApplicationController
  #before_action :require_login
  before_action :set_agent, only: [:show, :edit, :update, :destroy]

  def index
    @agents = Agent.all
  end

  def show
  end

  def new
    @agent = Agent.new
  end

  def edit
  end

  def create
    @agent = Agent.new(agent_params)

    if @agent.save
      redirect_to agents_path, notice: 'Agente creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @agent.update(agent_params)
      redirect_to agents_path, notice: 'Agente actualizado.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @agent.destroy
    redirect_to agents_path, notice: 'Agente eliminado.'
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:name, :role, :model_preferred, :active, :config)
  end
end
