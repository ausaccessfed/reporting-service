# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :ensure_authenticated

  def self.redis
    Rails.application.config.redis_client
  end

  def show
    public_action
    redis_active = redis_active?
    db_active = db_active?

    render json: {
      version: Rails.application.config.reporting_service.version,
      redis_active:,
      db_active:
    }, status: db_active && redis_active ? 200 : 503
  end

  private

  def redis_active?
    # :nocov:
    HealthController.redis&.ping && true
    # :nocov:
  rescue StandardError
    false
  end

  def db_active?
    ActiveRecord::Base.connection.active?
  rescue StandardError
    false
  end
end
