require 'rails_helper'

RSpec.describe ComplianceReportsController, type: :controller do
  let(:user) { create(:subject) }
  before { session[:subject_id] = user.try(:id) }

  shared_examples 'get request' do
    let!(:provider) { create object }
    let!(:activation) { create(:activation, federation_object: provider) }

    context 'with no user' do
      let(:user) { nil }

      it 'requires authentication' do
        run
        expect(response).to redirect_to('/auth/login')
      end
    end

    def run
      get route_path
    end

    it 'renders the page' do
      run
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("compliance_reports#{template}")
    end

    it 'assigns the objects' do
      run
      expect(assigns["#{object}s".to_sym]).to include(provider)
    end

    it 'excludes inactive objects' do
      activation.update!(deactivated_at: 1.second.ago.utc)
      run
      expect(assigns["#{object}s".to_sym]).not_to include(provider)
    end
  end

  shared_examples 'post request' do
    let!(:provider) { create object }
    let!(:activation) { create(:activation, federation_object: provider) }

    def run
      post route_path, "#{finder}": provider.send(finder)
    end

    it 'renders the page' do
      run
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("compliance_reports#{template}")
    end

    it 'assigns the objects' do
      run
      expect(assigns["#{object}s".to_sym]).to include(provider)
    end

    it 'assigns the name or entity_id' do
      run
      expect(assigns[finder]).to eq(provider.send(finder))
    end

    it 'assigns the report data' do
      run
      expect(assigns[:data]).to be_a(String)
      data = JSON.parse(assigns[:data], symbolize_names: true)
      expect(data[:type]).to eq(cache_type)
    end
  end

  describe 'get & post on /service_provider/compatibility_report' do
    let(:object) { :service_provider }
    let(:route_path) { :service_provider_compatibility_report }
    let(:cache_type) { 'service-compatibility' }
    let(:finder) { :entity_id }

    let(:template) do
      '/service_provider_compatibility_report'
    end

    it_behaves_like 'post request'
    it_behaves_like 'get request'
  end

  describe 'get on /identity_provider/attributes_report' do
    let(:object) { :identity_provider }
    let(:route_path) { :identity_provider_attributes_report }

    let(:template) do
      '/identity_provider_attributes_report'
    end

    it_behaves_like 'get request'
  end
end
