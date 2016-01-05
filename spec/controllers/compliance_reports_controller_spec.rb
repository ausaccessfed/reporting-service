require 'rails_helper'

RSpec.describe ComplianceReportsController, type: :controller do
  let(:user) { create(:subject) }
  before { session[:subject_id] = user.try(:id) }

  describe 'get :service_provider_compatibility_report' do
    let!(:sp) { create(:service_provider) }
    let!(:activation) { create(:activation, federation_object: sp) }

    context 'with no user' do
      let(:user) { nil }

      it 'requires authentication' do
        run
        expect(response).to redirect_to('/auth/login')
      end
    end

    def run
      get :service_provider_compatibility_report
    end

    it 'renders the page' do
      run
      expect(response).to have_http_status(:ok)
      template = 'compliance_reports/service_provider_compatibility_report'
      expect(response).to render_template(template)
    end

    it 'assigns the identity providers' do
      run
      expect(assigns[:service_providers]).to include(sp)
    end

    it 'excludes inactive identity providers' do
      activation.update!(deactivated_at: 1.second.ago.utc)
      run
      expect(assigns[:service_providers]).not_to include(sp)
    end
  end

  describe 'post :service_provider_compatibility_report' do
    let!(:sp) { create(:service_provider) }
    let!(:activation) { create(:activation, federation_object: sp) }

    def run
      post :service_provider_compatibility_report, entity_id: sp.entity_id
    end

    it 'renders the page' do
      run
      expect(response).to have_http_status(:ok)
      template = 'compliance_reports/service_provider_compatibility_report'
      expect(response).to render_template(template)
    end

    it 'assigns the identity providers' do
      run
      expect(assigns[:service_providers]).to include(sp)
    end

    it 'assigns the entity_id' do
      run
      expect(assigns[:entity_id]).to eq(sp.entity_id)
    end

    it 'assigns the report data' do
      run
      expect(assigns[:data]).to be_a(String)
      data = JSON.parse(assigns[:data], symbolize_names: true)
      expect(data[:type]).to eq('service-compatibility')
    end
  end
end
