Rails.application.routes.draw do
  get '/dashboard' => 'dashboard#index', as: 'dashboard'
  root to: 'welcome#index'
end
