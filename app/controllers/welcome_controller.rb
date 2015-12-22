class WelcomeController < ApplicationController
  skip_before_action :ensure_authenticated

  def index
    public_action
    return dashboard_path if subject && !request.get?
    redirect_to session[:request_url] || dashboard_path if subject
  end
end
