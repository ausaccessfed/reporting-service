require 'rails_helper'

RSpec.describe ServiceProviderReportsController, type: :controller do
  def run_get
    get report_path
  end

  def run_post
    post report_path,
         entity_id: object.entity_id,
         start: 1.year.ago.utc, end: Time.now.utc
  end

  shared_examples 'a Service Provider Report Controller' do
    let(:organization) { create :organization }
    let(:object) { create :service_provider, organization: organization }
    let(:bad_object) { create :service_provider }

    let(:user) do
      create :subject, :authorized,
             permission:
             "objects:organization:#{organization.identifier}:report"
    end

    before do
      session[:subject_id] = user.try(:id)
      create :activation, federation_object: object
      create :activation, federation_object: bad_object
    end

    context 'with no user' do
      let(:user) { nil }

      it 'requires authentication' do
        run_get
        expect(response).to redirect_to('/auth/login')
      end
    end

    context 'with user' do
      it 'assigns only permitted SPs to the SPs list' do
        run_get
        expect(assigns[:service_providers]).to include(object)
        expect(assigns[:service_providers]).not_to include(bad_object)
      end
    end

    context 'generate sessions report' do
      it 'assigns only permitted SPs to the SPs list' do
        run_post
        expect(assigns[:data]).to be_a(String)
        data = JSON.parse(assigns[:data], symbolize_names: true)
        expect(data[:type]).to eq(template)
      end
    end
  end

  context 'Service Provider Sessions Report' do
    let(:report_path) { :sessions_report }
    let(:template) { 'service-provider-sessions' }
    it_behaves_like 'a Service Provider Report Controller'
  end

  context 'Service Provider Daily Demand Report' do
    let(:report_path) { :daily_demand_report }
    let(:template) { 'service-provider-daily-demand' }
    it_behaves_like 'a Service Provider Report Controller'
  end

  context 'Service Provider Daily Demand Report' do
    let(:report_path) { :source_identity_providers_report }
    let(:template) { 'service-provider-source-identity-providers' }
    it_behaves_like 'a Service Provider Report Controller'
  end
end
