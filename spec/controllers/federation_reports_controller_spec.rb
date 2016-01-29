require 'rails_helper'

RSpec.describe FederationReportsController, type: :controller do
  let(:user) { create(:subject) }

  before { session[:subject_id] = user.try(:id) }

  shared_examples 'a federation report controller' do
    let(:data) { { a: 1 } }

    def run
      expect_any_instance_of(report_class).to receive(:generate)
        .and_return(data)
      get route_value.to_sym
    end

    before { run }

    it 'renders the page successfully' do
      expect(response).to have_http_status(:ok)
      expect(response)
        .to render_template("federation_reports/#{route_value}")
    end

    it 'assigns the report data' do
      expect(assigns[:data]).to eq('{"a":1}')
    end

    it 'caches the report data' do
      expect(Rails.cache.fetch("public/#{cach_template}")).to eq('{"a":1}')
    end

    context 'with cached data' do
      def run
        expect_any_instance_of(report_class).not_to receive(:generate)
        Rails.cache.fetch("public/#{cach_template}") { '{"b":2}' }
        get route_value.to_sym
      end

      it 'assigns the cached report data' do
        expect(assigns[:data]).to eq('{"b":2}')
      end
    end
  end

  context 'get :federation_growth' do
    let(:report_class) { FederationGrowthReport }
    let(:route_value) { 'federation_growth' }
    let(:cach_template) { 'federation-growth' }

    it_behaves_like 'a federation report controller'
  end

  context 'get :federated_sessions' do
    let(:report_class) { FederatedSessionsReport }
    let(:route_value) { 'federated_sessions' }
    let(:cach_template) { 'federated-sessions' }

    it_behaves_like 'a federation report controller'
  end

  context 'get :daily_demand' do
    let(:report_class) { DailyDemandReport }
    let(:route_value) { 'daily_demand' }
    let(:cach_template) { 'daily-demand' }

    it_behaves_like 'a federation report controller'
  end
end
