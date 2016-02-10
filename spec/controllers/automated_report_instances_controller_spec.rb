require 'rails_helper'

RSpec.describe AutomatedReportInstancesController, type: :controller do
  let(:organization) { create :organization }
  let(:idp) { create :identity_provider }

  let(:user) { create :subject }

  let!(:auto_report) do
    create :automated_report,
           report_class: 'IdentityProviderSessionsReport',
           target: idp.entity_id
  end

  let!(:subscription) do
    create :automated_report_subscription,
           automated_report: auto_report,
           subject: user
  end

  before do
    session[:subject_id] = user.try(:id)
    create :activation, federation_object: idp
    get :show, report_id: subscription.identifier
  end

  describe 'get on /automated_reports' do
    it 'should response with 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'should render the show template' do
      expect(response).to render_template('show')
    end
  end
end
