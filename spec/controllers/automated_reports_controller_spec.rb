require 'rails_helper'

RSpec.describe AutomatedReportsController, type: :controller do
  let(:organization) { create :organization }
  let(:idp) { create :identity_provider }

  let(:user) do
    create :subject, :authorized,
           permission:
           "objects:organization:#{organization.identifier}:report"
  end

  let!(:auto_report) do
    create :automated_report,
           report_class: 'IdentityProviderSessionsReport',
           target: idp.entity_id
  end

  let!(:auto_report_sub) do
    create :automated_report_subscription,
           automated_report: auto_report,
           subject: user
  end

  let!(:auto_report_instance) { create :automated_report_instance }

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

    it 'should list automated reports' do
      expect(assigns[:reports]).to include('*')
    end
  end
end
