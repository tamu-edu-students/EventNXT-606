class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #before_action :authenticate_user!, :except => []
  # protect_from_forgery prepend: true, with: :exception
  helper_method :current_user
  protected

  def render_not_found
    render file: Rails.root.join('public', '404.html'), status: 404;
  end

  def current_user
    if doorkeeper_token
      Rails.logger.debug "Doorkeeper token found: #{doorkeeper_token.inspect}"
      @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
      Rails.logger.debug "Current user: #{@current_user.inspect}"
    end
  end
end
