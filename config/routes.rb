require 'api_constraints'

Rails.application.routes.draw do
  get '/dashboard' => 'dashboard#index', as: 'dashboard'
  root to: 'welcome#index'

  namespace :api, defaults: { format: 'json' } do
    v1_constraints = APIConstraints.new(version: 1, default: true)
    scope constraints: v1_constraints do
    end
  end
end
