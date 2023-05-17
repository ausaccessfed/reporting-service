# frozen_string_literal: true

class ErrorController < ApplicationController
  skip_before_action :ensure_authenticated

  def page_not_found
    public_action

    respond_to do |format|
      format.html { render template: 'errors/not_found_error', layout: 'layouts/application', status: :not_found }
      format.all  { render nothing: true, status: :not_found }
    end
  end

  def server_error
    public_action

    respond_to do |format|
      format.html do
        render template: 'errors/internal_server_error', layout: 'layouts/error', status: :internal_server_error
      end
      format.all { render nothing: true, status: :internal_server_error }
    end
  end
end
