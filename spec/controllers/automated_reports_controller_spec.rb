require 'rails_helper'

RSpec.describe AutomatedReportsController, type: :controller do
  let(:organization) { create :organization }
  let(:idp) { create :identity_provider }

  let(:user) { create :subject }

  let(:auto_report) do
    create :automated_report,
           report_class: 'IdentityProviderSessionsReport',
           target: idp.entity_id
  end

  let(:subscription) do
    create :automated_report_subscription,
           automated_report: auto_report,
           subject: user
  end

  def destroy
    delete :destroy, report_id: subscription.identifier
  end

  before do
    session[:subject_id] = user.try(:id)
    create :activation, federation_object: idp
    get :index
  end

  describe 'get on /automated_reports' do
    it 'should response with 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'should render the index template' do
      expect(response).to render_template('index')
    end

    it 'should assign subject\'t automated report subscriptions' do
      expect(assigns[:subscriptions]).to include(subscription)
    end
  end

  describe 'post on /automated_reports/destroy' do
    before { destroy }

    it 'should response with redirect (302)' do
      expect(response).to redirect_to('/automated_reports')
    end

    it 'should destroy automated report subscription' do
      expect(assigns[:subscriptions]).not_to include(subscription)
    end
  end
end
