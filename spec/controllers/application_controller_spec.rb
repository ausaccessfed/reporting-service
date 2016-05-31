# frozen_string_literal: true
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
      match ':controller/:action(/:id)', via: [:get, :post]
    end
  end

  context 'when request is session' do
    it 'POST request should not create a uri session' do
      post :federation_growth
      expect(session).not_to include(:return_url)
    end

    it 'GET request should not create a uri session' do
      get :federation_growth
      uri = URI.parse(session[:return_url])
      expect(uri.path).to eq('/anonymous/federation_growth')
      expect(uri.query).to be_blank
      expect(uri.fragment).to be_blank
    end

    it 'GET request should create a uri session including fragments' do
      get :federation_growth, time: 1000
      uri = URI.parse(session[:return_url])

      expect(uri.path).to eq('/anonymous/federation_growth')
      expect(uri.query).to eq('time=1000')
      expect(uri.fragment).to be_blank
    end
  end
end
