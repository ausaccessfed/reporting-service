# frozen_string_literal: true

class HealthController < ApplicationController
  publicly_accessible

  def self.redis
    Redis.new(
      url: Rails.application.config.hosted_idp_service[:redis][:url],
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    )
  end

  def show
    redis_active = redis_active?
    db_active = db_active?

    render json: {
      version: Rails.application.config.hosted_idp_service[:version],
      redis_active: redis_active,
      db_active: db_active
    }, status: db_active && redis_active ? 200 : 503
  end

  private

  def redis_active?
    HealthController.redis&.ping && true
  rescue StandardError
    false
  end

  def db_active?
    ActiveRecord::Base.connection.active?
  rescue StandardError
    false
  end
end
