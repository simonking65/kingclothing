class SessionsController < ApplicationController
  skip_before_action :authorize
  def new
  end

  def create
    if User.any?
  	 user = User.find_by(name: params[:name])
  	 if user and user.authenticate(params[:password])
  	 	 session[:user_id] = user.id
  	   redirect_to admin_url
  	 else
  	 	 redirect_to login_url, alert: "Invalid user/password combination"
		  end
    else
      #new_user = User.create(name: params[:name], password: params[:password], password_confirmation: params[:password])
      #session[:user_id] = new_user.id
      redirect_to admin_url
    end
  end

  def destroy
  	session[:user_id] = nil
  	redirect_to store_url, notice: "Logged out"
  end
end
