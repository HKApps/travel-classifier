class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    @user ||= begin
      user = User.find_by google_id: session[:auth_id]
      user if user && user.expires_at > DateTime.now
    end
  end
  helper_method :current_user

  def ensure_logged_in
    redirect_to new_session_url unless current_user
  end
end
