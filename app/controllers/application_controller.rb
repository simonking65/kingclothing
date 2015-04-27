class ApplicationController < ActionController::Base
  before_action :authorize
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  	def authorize
      #debugger
  		if request.format == Mime::HTML
  			unless User.find_by(id: session[:user_id])
  				redirect_to login_url, notice: "Please log in"
  		else
  			authenticate_or_request_with_http_basic('Kingclothing') do |username, password|
  				username == 'Ollie' && password=='light9610*'
  				user = User.find_by_name('Ollie')
  				session[:user_id] = user.id
  			end
  		end
		end
end
end