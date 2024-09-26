# frozen_string_literal: true

require 'api_constraints'

Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'

  get '/dashboard' => 'dashboard#index', :as => 'dashboard'
  root to: 'welcome#index'
  get 'health' => 'health#show'
  # Browsers often request /favicon.ico. This controller redirects to the actual favicon.
  resource :favicon, only: :show

  scope '/federation_reports' do
    get 'federation_growth_report' => 'federation_reports#federation_growth_report',
        :as => :public_federation_growth_report

    get 'federated_sessions_report' => 'federation_reports#federated_sessions_report',
        :as => :public_federated_sessions_report

    get 'daily_demand_report' => 'federation_reports#daily_demand_report', :as => :public_daily_demand_report
  end

  scope '/compliance_reports' do
    def match_report(prefix, name, http_verbs)
      match "/#{prefix}_#{name}", to: "compliance_reports##{prefix}_#{name}", via: http_verbs, as: :"#{prefix}_#{name}"
    end

    match_report('service_provider', 'compatibility_report', %i[get post])
    match_report('identity_provider', 'attributes_report', :get)
    match_report('attribute', 'identity_providers_report', %i[get post])
    match_report('attribute', 'service_providers_report', %i[get post])
  end

  get '/admin_reports' => 'administrator_reports#index', :as => :admin_reports

  scope '/admin_reports' do
    def match_report(name, http_verbs)
      match "/#{name}", to: "administrator_reports##{name}", via: http_verbs, as: :"admin_#{name}"
    end

    match_report('subscriber_registrations_report', %i[get post])
    match_report('federation_growth_report', %i[get post])
    match_report('daily_demand_report', %i[get post])
    match_report('federated_sessions_report', %i[get post])
    match_report('identity_provider_utilization_report', %i[get post])
    match_report('service_provider_utilization_report', %i[get post])
  end

  get '/subscriber_reports' => 'subscriber_reports_dashboard#index', :as => :subscriber_reports

  scope '/subscriber_reports' do
    def match_report(prefix, name, http_verbs)
      match "/#{prefix}_#{name}", to: "#{prefix}_reports##{name}", via: http_verbs, as: :"#{prefix}_#{name}"
    end

    match_report('identity_provider', 'sessions_report', %i[get post])
    match_report('identity_provider', 'daily_demand_report', %i[get post])
    match_report('identity_provider', 'destination_services_report', %i[get post])

    match_report('service_provider', 'sessions_report', %i[get post])
    match_report('service_provider', 'daily_demand_report', %i[get post])
    match_report('service_provider', 'source_identity_providers_report', %i[get post])
  end

  get 'automated_report/:identifier', to: 'automated_report_instances#show', as: :automated_report

  scope '/automated_reports' do
    get '/' => 'automated_reports#index', :as => :automated_reports
    post '/' => 'automated_reports#subscribe'
    delete '/:identifier' => 'automated_reports#destroy'
  end
end

RapidRack::Engine.routes.draw do
  opts = Rails.application.config.reporting_service.rapid_connect[:rack]
  authenticator = opts[:authenticator].constantize.new(opts)

  mount authenticator => ''
end
