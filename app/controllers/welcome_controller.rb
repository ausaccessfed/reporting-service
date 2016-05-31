# frozen_string_literal: true
class WelcomeController < ApplicationController
  skip_before_action :ensure_authenticated

  def index
    public_action
    redirect_to dashboard_path if subject
  end
end
