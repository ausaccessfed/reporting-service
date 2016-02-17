require 'rails_helper'

RSpec.describe AutomatedReportInstancesController, type: :controller do
  let(:organization) { create :organization }

  let(:user) do
    create :subject, :authorized,
           permission:
           "objects:organization:#{organization.identifier}:report"
  end

  REPORT_CLASSES_WITH_NIL_TARGET =
    %w(DailyDemandReport
       FederatedSessionsReport
       FederationGrowthReport
       IdentityProviderAttributesReport).freeze

  REPORT_CLASSES_WITH_NIL_TARGET.each_with_index do |klass, i|
    let!("instance_#{i}".to_sym) do
      create :automated_report_instance,
             automated_report: (create :automated_report,
                                       report_class: klass)
    end
  end

  def get_tamplate_name(type)
    type.chomp('Report').underscore.tr('_', '-')
  end

  def run(identifier)
    get :show, identifier: identifier
  end

  before do
    session[:subject_id] = user.try(:id)
  end

  describe 'get on /automated_reports' do
    it 'should response with 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns the report data correctly' do
      AutomatedReportInstance.all.each do |instance|
        run(instance.identifier)

        report_class = instance.automated_report.report_class
        data = JSON.parse(assigns[:data], symbolize_names: true)
        template = get_tamplate_name(report_class)

        expect(assigns[:data]).to be_a(String)
        expect(data[:type]).to eq(template)
        expect(response).to render_template('automated_report_instances/show')
      end
    end
  end

  describe 'access check on subscriber reports' do
    let(:idp) { create :identity_provider }

    let(:sp) do
      create :service_provider,
             organization: organization
    end

    let(:auto_report_idp) do
      create :automated_report,
             target: idp.entity_id,
             report_class: 'IdentityProviderSessionsReport'
    end

    let(:auto_report_sp) do
      create :automated_report,
             target: sp.entity_id,
             report_class: 'ServiceProviderDailyDemandReport'
    end

    let(:auto_report_admin) do
      create :automated_report,
             target: 'organizations',
             report_class: 'SubscriberRegistrationsReport'
    end

    let!(:report_instance_idp) do
      create :automated_report_instance,
             automated_report: auto_report_idp
    end

    let!(:report_instance_sp) do
      create :automated_report_instance,
             automated_report: auto_report_sp
    end

    let!(:report_instance_admin) do
      create :automated_report_instance,
             automated_report: auto_report_admin
    end

    context 'user without permission' do
      it 'should not view the report' do
        run(report_instance_idp.identifier)

        expect(assigns[:instance]).to be_nil
      end
    end

    context 'user with permission' do
      it 'should view the report' do
        run(report_instance_sp.identifier)

        expect(assigns[:instance]).to eq(report_instance_sp)
      end
    end

    context 'user without admin access' do
      it 'should not view the report' do
        run(report_instance_admin.identifier)

        expect(assigns[:instance]).to be_nil
      end
    end

    context 'user with admin access' do
      let(:user) { create :subject, :authorized, permission: 'admin:*' }

      it 'should view the report' do
        run(report_instance_admin.identifier)

        expect(assigns[:instance]).to eq(report_instance_admin)
      end
    end
  end
end
