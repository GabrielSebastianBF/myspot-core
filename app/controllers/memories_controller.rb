class MemoriesController < ApplicationController
  #before_action :require_login
  before_action :set_memory, only: [:show, :edit, :update, :destroy]

  def index
    @memories = Memory.order(created_at: :desc).limit(100)
  end

  def show
  end

  def new
    @memory = Memory.new
    @memory.agent_id = params[:agent_id]
  end

  def edit
  end

  def create
    @memory = Memory.new(memory_params)
    
    if @memory.save
      @memory.generate_embedding!
      redirect_to memories_path, notice: 'Memoria creada.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @memory.update(memory_params)
      @memory.generate_embedding!
      redirect_to memories_path, notice: 'Memoria actualizada.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @memory.destroy
    redirect_to memories_path, notice: 'Memoria eliminada.'
  end

  private

  def set_memory
    @memory = Memory.find(params[:id])
  end

  def memory_params
    params.require(:memory).permit(:content, :memory_type, :importance, :agent_id, :session_id)
  end
end
