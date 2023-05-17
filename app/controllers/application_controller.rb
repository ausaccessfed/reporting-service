# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Lipstick::DynamicErrors

  around_action :change_time_zone

  protect_from_forgery with: :exception
  before_action :ensure_authenticated
  after_action :ensure_access_checked

  def subject
    subject = session[:subject_id] && Subject.find_by(id: session[:subject_id])
    return nil unless subject.try(:functioning?)

    @subject = subject
  end

  def page_not_found
    respond_to do |format|
      format.html { render template: 'errors/not_found_error', layout: 'layouts/application', status: :not_found }
      format.all  { render nothing: true, status: :not_found }
    end
  end

  def server_error
    respond_to do |format|
      format.html do
        render template: 'errors/internal_server_error', layout: 'layouts/error', status: :internal_server_error
      end
      format.all { render nothing: true, status: :internal_server_error }
    end
  end

  protected

  def ensure_authenticated
    return force_authentication unless session[:subject_id]

    @subject = Subject.find_by(id: session[:subject_id])
    raise(Unauthorized, 'Subject invalid') unless @subject
    raise(Unauthorized, 'Subject not functional') unless @subject.functioning?
  end

  def ensure_access_checked
    return if @access_checked

    method = "#{self.class.name}##{params[:action]}"
    raise("No access control performed by #{method}")
  end

  def check_access!(action)
    raise(Forbidden) unless subject.permits?(action)

    @access_checked = true
  end

  def public_action
    @access_checked = true
  end

  def force_authentication
    session[:return_url] = request.url if request.get? || request.head?

    redirect_to('/auth/login')
  end

  def change_time_zone(&block)
    timezone = configuration.time_zone
    Time.use_zone(timezone, &block)
  end

  def configuration
    Rails.application.config.reporting_service
  end
end
