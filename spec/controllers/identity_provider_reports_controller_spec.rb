require 'rails_helper'

RSpec.describe IdentityProviderReportsController, type: :controller do
  def run_get
    get report_path
  end

  def run_post
    post report_path,
         entity_id: object.entity_id,
         start: 1.year.ago.utc, end: Time.now.utc
  end

  shared_examples 'an Identity Provider Report Controller' do
    let(:organization) { create :organization }
    let(:object) { create :identity_provider, organization: organization }
    let(:bad_object) { create :identity_provider }

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
      it 'assigns only permitted IdP to the IdPs list' do
        run_get
        expect(assigns[:entities]).to include(object)
        expect(assigns[:entities]).not_to include(bad_object)
      end
    end

    context 'generate report' do
      it 'assigns only permitted IdP to the IdPs list' do
        run_post
        expect(assigns[:data]).to be_a(String)
        data = JSON.parse(assigns[:data], symbolize_names: true)
        expect(data[:type]).to eq(template)
      end
    end
  end

  context 'Identity Provider Sessions Report' do
    let(:report_path) { :sessions_report }
    let(:template) { 'identity-provider-sessions' }
    it_behaves_like 'an Identity Provider Report Controller'
  end

  context 'Identity Provider Daily Demand Report' do
    let(:report_path) { :daily_demand_report }
    let(:template) { 'identity-provider-daily-demand' }
    it_behaves_like 'an Identity Provider Report Controller'
  end

  context 'Identity Provider Destination Services' do
    let(:report_path) { :destination_services_report }
    let(:template) { 'identity-provider-destination-services' }
    it_behaves_like 'an Identity Provider Report Controller'
  end
end
