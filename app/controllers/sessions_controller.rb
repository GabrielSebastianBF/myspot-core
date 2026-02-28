class SessionsController < ApplicationController
  # Skip authentication for this controller
  skip_before_action :verify_authenticity_token, only: [:create]
  
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:user_name] = user.name
      session[:user_role] = user.role
      
      redirect_to dashboard_path, notice: "Bienvenido#{user.name ? ' ' + user.name : ''}!"
    else
      flash.now[:alert] = 'Email o contraseña incorrectos'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.destroy
    redirect_to login_path, notice: 'Sesión cerrada.'
  end
end
