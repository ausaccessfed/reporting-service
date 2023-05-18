# frozen_string_literal: true

redis_namespace = "#{Rails.application.config.reporting_service.redis[:namespace]}:#{Rails.env}:session"

session_store_opts = {
  redis_server: "#{Rails.application.config.reporting_service.redis[:url]}/#{redis_namespace}",
  expire_after: 3600,
  secure: false,
  key: "_#{Rails.application.config.reporting_service.redis[:namespace]}-session"
}

Rails.application.config.session_store(:redis_store, session_store_opts)
