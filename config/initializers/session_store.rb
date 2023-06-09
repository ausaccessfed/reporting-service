# frozen_string_literal: true

# redis_namespace = "#{Rails.application.config.reporting_service.redis[:namespace]}:#{Rails.env}:session"
# session_cookie_secure = false

# session_store_opts = {
#   servers: ["#{Rails.application.config.reporting_service.redis[:url]}/#{redis_namespace}?ssl_cert_reqs=CERT_NONE"],
#   expire_after: 3600,
#   secure: session_cookie_secure,
#   key: "_#{Rails.application.config.reporting_service.redis[:namespace]}-session"
# }

# Rails.application.config.session_store(:redis_store, session_store_opts)

Rails.application.config.session_store :active_record_store,
                                       key: "_#{Rails.application.config.reporting_service.redis[:namespace]}-session",
                                       secure: Rails.env.production?,
                                       expires: 90.minutes
