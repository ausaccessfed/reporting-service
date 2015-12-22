require 'rails_helper'
require 'gumboot/shared_examples/application_controller'

RSpec.describe ApplicationController, type: :controller do
  include_examples 'Application controller'
  controller do
    before_action :ensure_authenticated

    def federation_growth
      public_action
      render nothing: true
    end
  end

  before do
    @routes.draw do
      post '/anonymous/federation_growth' => 'anonymous#federation_growth'
      get '/anonymous/federation_growth' => 'anonymous#federation_growth'
    end
  end

  context 'when request is session' do
    it 'POST request should redirect to dashboard_path' do
      post :federation_growth
      expect(session).not_to include(:request_url)
    end

    it 'GET request should redirect to request.url' do
      get :federation_growth
      expect(session).to include(:request_url)
      expect(session[:request_url]).to include('/anonymous/federation_growth')
    end
  end
end
