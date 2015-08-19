Rails.application.configure do
  app_config = YAML.load(Rails.root.join('config/reporting_service.yml').read)
  config.reporting_service = OpenStruct.new(app_config.deep_symbolize_keys)
end
