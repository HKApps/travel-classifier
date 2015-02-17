class SessionsController < ApplicationController
  layout false

  def new
  end

  def create
    auth  = request.env['omniauth.auth']
    @user = UserCreationService.create_or_update!(auth)
  end
end
