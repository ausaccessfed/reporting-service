require 'api_constraints'

Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'

  get '/dashboard' => 'dashboard#index', as: 'dashboard'
  root to: 'welcome#index'

  scope '/federation_reports' do
    get 'federation_growth' => 'federation_reports#federation_growth',
        as: :public_federation_growth_report
  end

  scope '/compliance_reports' do
    def match_report(prefix, name)
      match "/#{prefix}/#{name}", to: "compliance_reports##{prefix}_#{name}",
                                  via: [:get, :post], as: :"#{prefix}_#{name}"
    end

    match_report('service_provider', 'compatibility_report')
  end

  namespace :api, defaults: { format: 'json' } do
    v1_constraints = APIConstraints.new(version: 1, default: true)
    scope constraints: v1_constraints do
    end
  end
end
