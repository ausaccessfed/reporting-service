require 'rails_helper'

RSpec.describe IdentityProviderReportsController, type: :controller do
  let(:organization) { create :organization }
  let(:idp_01) { create :identity_provider, organization: organization }
  let(:idp_02) { create :identity_provider }

  let(:user) do
    create :subject, :authorized,
           permission:
           "objects:organization:#{organization.identifier}:report"
  end

  before do
    session[:subject_id] = user.try(:id)
    create :activation, federation_object: idp_01
    create :activation, federation_object: idp_02
  end

  def run_get
    get :sessions_report
  end

  def run_post
    post :sessions_report,
         entity_id: idp_01.entity_id,
         start: 1.year.ago.utc, end: Time.now.utc
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
      expect(assigns[:identity_providers]).to include(idp_01)
      expect(assigns[:identity_providers]).not_to include(idp_02)
    end
  end

  context 'generate sessions report' do
    it 'assigns only permitted IdP to the IdPs list' do
      run_post
      expect(assigns[:data]).to be_a(String)
      data = JSON.parse(assigns[:data], symbolize_names: true)
      expect(data[:type]).to eq('identity-provider-sessions')
    end
  end
end
