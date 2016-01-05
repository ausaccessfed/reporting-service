require 'rails_helper'

RSpec.describe FederationReportsController, type: :controller do
  let(:user) { create(:subject) }

  before { session[:subject_id] = user.try(:id) }

  describe 'get :federation_growth' do
    let(:data) { { a: 1 } }

    def run
      expect_any_instance_of(FederationGrowthReport).to receive(:generate)
        .and_return(data)
      get :federation_growth
    end

    before { run }

    it 'renders the page successfully' do
      expect(response).to have_http_status(:ok)
      expect(response)
        .to render_template('federation_reports/federation_growth')
    end

    it 'assigns the report data' do
      expect(assigns[:data]).to eq('{"a":1}')
    end

    it 'caches the report data' do
      expect(Rails.cache.fetch('public/federation-growth')).to eq('{"a":1}')
    end

    context 'with cached data' do
      def run
        expect_any_instance_of(FederationGrowthReport).not_to receive(:generate)
        Rails.cache.fetch('public/federation-growth') { '{"b":2}' }
        get :federation_growth
      end

      it 'assigns the cached report data' do
        expect(assigns[:data]).to eq('{"b":2}')
      end
    end
  end
end
