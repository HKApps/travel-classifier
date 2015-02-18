class SessionsController < ApplicationController
  def create
    auth  = request.env['omniauth.auth']
    @user = UserCreationService.create_or_update!(auth)
    session[:auth_id] = @user.google_id
    redirect_to :root
  end
end
