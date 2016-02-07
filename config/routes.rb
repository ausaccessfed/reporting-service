require 'api_constraints'

Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'

  get '/dashboard' => 'dashboard#index', as: 'dashboard'
  root to: 'welcome#index'

  scope '/federation_reports' do
    get 'federation_growth' => 'federation_reports#federation_growth',
        as: :public_federation_growth_report

    get 'federated_sessions' => 'federation_reports#federated_sessions',
        as: :public_federated_sessions_report

    get 'daily_demand' => 'federation_reports#daily_demand',
        as: :public_daily_demand_report
  end

  scope '/compliance_reports' do
    def match_report(prefix, name, verbs)
      match "/#{prefix}/#{name}", to: "compliance_reports##{prefix}_#{name}",
                                  via: verbs, as: :"#{prefix}_#{name}"
    end

    match_report('service_provider', 'compatibility_report', [:get, :post])
    match_report('identity_provider', 'attributes_report', :get)
    match_report('attribute', 'identity_providers_report', [:get, :post])
    match_report('attribute', 'service_providers_report', [:get, :post])
  end

  get '/admin/reports' => 'administrator_reports#index',
      as: :admin_reports

  scope '/admin' do
    def match_report(prefix, name, verbs)
      match "/#{prefix}/#{name}", to: "administrator_reports##{name}",
                                  via: verbs, as: :"admin_#{prefix}_#{name}"
    end

    match_report('reports', 'subscriber_registrations_report', [:get, :post])
    match_report('reports', 'federation_growth_report', [:get, :post])
    match_report('reports', 'daily_demand_report', [:get, :post])
    match_report('reports', 'federated_sessions_report', [:get, :post])
  end

  get '/subscriber_reports' => 'subscriber_reports_dashboard#index',
      as: 'subscriber_reports'

  scope '/subscriber_reports' do
    def match_report(prefix, name, http_verbs)
      match "/#{prefix}/#{name}",
            to: "#{prefix}_reports##{name}",
            via: http_verbs, as: :"#{prefix}_#{name}"
    end

    match_report('identity_provider', 'sessions_report', [:get, :post])
    match_report('identity_provider', 'daily_demand_report', [:get, :post])
    match_report('identity_provider',
                 'destination_services_report', [:get, :post])

    match_report('service_provider', 'sessions_report', [:get, :post])
    match_report('service_provider', 'daily_demand_report', [:get, :post])
    match_report('service_provider',
                 'source_identity_providers_report', [:get, :post])
  end

  get '/automated_reports' => 'automated_reports#index', via: :get,
      as: :automated_reports

  namespace :api, defaults: { format: 'json' } do
    v1_constraints = APIConstraints.new(version: 1, default: true)
    scope constraints: v1_constraints do
    end
  end
end
