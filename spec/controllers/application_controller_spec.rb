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

  context 'use time zone around filter' do
    let(:user) { create :subject, :authorized }
    let!(:zone) { Faker::Address.time_zone }

    before { session[:subject_id] = user.try(:id) }

    class SomeReportsController < ApplicationController; end

    controller SomeReportsController do
      before_action :ensure_authenticated

      def report_action
        public_action

        @text = Time.zone.name
        render nothing: true
      end
    end

    before { Rails.application.config.reporting_service.time_zone = zone }

    specify 'inside action scope' do
      routes.draw { get 'report_action' => 'some_reports#report_action' }

      get :report_action
      expect(assigns[:text]).to eq(zone)
      expect(Time.zone.name).to eq('UTC')
    end
  end
end
