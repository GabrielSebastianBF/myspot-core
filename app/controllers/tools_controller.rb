class ToolsController < ApplicationController
  #before_action :require_login
  before_action :set_tool, only: [:show, :edit, :update, :destroy]

  def index
    @tools = Tool.all
  end

  def show
  end

  def new
    @tool = Tool.new
  end

  def edit
  end

  def create
    @tool = Tool.new(tool_params)

    if @tool.save
      redirect_to tools_path, notice: 'Herramienta creada.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tool.update(tool_params)
      redirect_to tools_path, notice: 'Herramienta actualizada.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tool.destroy
    redirect_to tools_path, notice: 'Herramienta eliminada.'
  end

  private

  def set_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
    params.require(:tool).permit(:name, :description, :enabled, :allowed_roles, :schema)
  end
end
