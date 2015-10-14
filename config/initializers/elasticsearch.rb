Rails.application.configure do
  config.elasticsearch = config_for(:elasticsearch).with_indifferent_access
end
