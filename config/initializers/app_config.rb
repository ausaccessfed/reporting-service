Rails.application.configure do
  app_config = YAML.load(Rails.root.join('config/reporting_service.yml').read)
  config.reporting_service = OpenStruct.new(app_config.deep_symbolize_keys)

  if Rails.env.test?
    config.reporting_service.ide = {
      host: 'ide.example.edu',
      cert: 'spec/api.crt',
      key: 'spec/api.key'
    }
  end
end
