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

  shared_examples 'Automated Subscriber Report' do
    let(:object) do
      create object_type, organization: organization
    end

    let(:auto_report) do
      create :automated_report,
             target: object.entity_id,
             report_class: report_class
    end

    let!(:instance) do
      create :automated_report_instance,
             automated_report: auto_report
    end

    let(:unpermitted_object) { create object_type }

    let!(:unpermitted_auto_report) do
      create :automated_report,
             target: unpermitted_object.entity_id,
             report_class: report_class
    end

    let!(:unpermitted_instance) do
      create :automated_report_instance,
             automated_report: unpermitted_auto_report
    end

    context 'subject with no permissions' do
      it 'should not be able to view the report' do
        run(unpermitted_instance.identifier)

        expect(assigns[:instance]).to be_nil
      end
    end

    context 'subject with subscriber access level' do
      it 'should be able to view the report' do
        run(instance.identifier)

        expect(assigns[:instance]).to eq(instance)
      end
    end

    context 'subject with admin access level' do
      let(:user) { create :subject, :authorized, permission: 'admin:*' }

      it 'should be able to view all types of reports' do
        run(instance.identifier)
        expect(assigns[:instance]).to eq(instance)

        run(unpermitted_instance.identifier)
        expect(assigns[:instance]).to eq(unpermitted_instance)
      end
    end
  end

  context 'Identity Provider Sessions Report' do
    let(:object_type) { :identity_provider }
    let(:report_class) { 'IdentityProviderSessionsReport' }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Identity Provider Daily Demand Report' do
    let(:object_type) { :identity_provider }
    let(:report_class) { 'IdentityProviderDailyDemandReport' }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Identity Provider Destination Services Report' do
    let(:object_type) { :identity_provider }
    let(:report_class) { 'IdentityProviderDestinationServicesReport' }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Service Provider Sessions Report' do
    let(:object_type) { :service_provider }
    let(:report_class) { 'ServiceProviderSessionsReport' }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Service Provider Daily Demand Report' do
    let(:object_type) { :service_provider }
    let(:report_class) { 'ServiceProviderDailyDemandReport' }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Service Provider Source Identity Providers Report' do
    let(:object_type) { :service_provider }
    let(:report_class) { 'ServiceProviderSourceIdentityProvidersReport' }

    it_behaves_like 'Automated Subscriber Report'
  end

  shared_examples 'Automated Subscriber Registrations Report' do
    let(:admin_auto_report) do
      create :automated_report,
             target: target,
             report_class: 'SubscriberRegistrationsReport'
    end

    let!(:admin_instance) do
      create :automated_report_instance,
             automated_report: admin_auto_report
    end

    before { run(admin_instance.identifier) }

    context 'only subject with admin access level' do
      let(:user) { create :subject, :authorized, permission: 'admin:*' }

      it 'can view this report' do
        expect(assigns[:instance]).to eq(admin_instance)
      end
    end

    context 'subject without admin access level' do
      it 'cannot view this report' do
        expect(assigns[:instance]).to be_nil
      end
    end
  end

  context 'IdPs Subscriber Registrations Report' do
    let(:target) { 'identity_providers' }

    it_behaves_like 'Automated Subscriber Registrations Report'
  end

  context 'SPs Subscriber Registrations Report' do
    let(:target) { 'service_providers' }

    it_behaves_like 'Automated Subscriber Registrations Report'
  end

  context 'Organizations Subscriber Registrations Report' do
    let(:target) { 'organizations' }

    it_behaves_like 'Automated Subscriber Registrations Report'
  end

  context 'Rapid Connect Subscriber Registrations Report' do
    let(:target) { 'rapid_connect_services' }

    it_behaves_like 'Automated Subscriber Registrations Report'
  end

  context 'Services Subscriber Registrations Report' do
    let(:target) { 'services' }

    it_behaves_like 'Automated Subscriber Registrations Report'
  end
end
