require 'rails_helper'

RSpec.describe AutomatedReportInstancesController, type: :controller do
  let(:organization) { create :organization }

  let(:user) do
    create :subject, :authorized,
           permission:
           "objects:organization:#{organization.identifier}:report"
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

  shared_examples 'Automated Public Report' do
    let(:auto_report) do
      create :automated_report,
             target: target,
             report_class: report_class
    end

    let!(:instance) do
      create :automated_report_instance,
             automated_report: auto_report
    end

    it 'all subjects can view public reports' do
      run(instance.identifier)

      data = JSON.parse(assigns[:data], symbolize_names: true)
      template = get_tamplate_name(report_class)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('automated_report_instances/show')
      expect(assigns[:data]).to be_a(String)
      expect(data[:type]).to eq(template)
      expect(assigns[:instance]).to eq(instance)
    end
  end

  context 'Automated Federation Report' do
    let(:target) { nil }

    report_classes = %w(FederationGrowthReport
                        FederatedSessionsReport
                        DailyDemandReport
                        IdentityProviderAttributesReport)

    report_classes.each do |klass|
      let(:report_class) { klass }

      it_behaves_like 'Automated Public Report'
    end
  end

  context 'Automated Federation Attributes Report' do
    let(:attribute) { create :saml_attribute }
    let(:target) { attribute.name }

    report_classes = %w(ProvidedAttributeReport
                        RequestedAttributeReport)

    report_classes.each do |klass|
      let(:report_class) { klass }

      it_behaves_like 'Automated Public Report'
    end
  end

  context 'Automated Federation Compatibility Report' do
    let(:attribute) { create :service_provider }
    let(:target) { attribute.entity_id }
    let(:report_class) { 'ServiceCompatibilityReport' }

    it_behaves_like 'Automated Public Report'
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

    it 'should render the template' do
      run(instance.identifier)

      data = JSON.parse(assigns[:data], symbolize_names: true)
      template = get_tamplate_name(report_class)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('automated_report_instances/show')
      expect(assigns[:data]).to be_a(String)
      expect(data[:type]).to eq(template)
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
    report_classes = %w(IdentityProviderSessionsReport
                        IdentityProviderDailyDemandReport
                        IdentityProviderDestinationServicesReport)

    report_classes.each do |klass|
      let(:object_type) { :identity_provider }
      let(:report_class) { klass }

      it_behaves_like 'Automated Subscriber Report'
    end
  end

  context 'Service Provider Sessions Report' do
    report_classes = %w(ServiceProviderSessionsReport
                        ServiceProviderDailyDemandReport
                        ServiceProviderSourceIdentityProvidersReport)

    report_classes.each do |klass|
      let(:object_type) { :service_provider }
      let(:report_class) { klass }

      it_behaves_like 'Automated Subscriber Report'
    end
  end

  shared_examples 'Automated Subscriber Registrations Report' do
    let(:auto_report) do
      create :automated_report,
             target: target,
             report_class: 'SubscriberRegistrationsReport'
    end

    let!(:instance) do
      create :automated_report_instance,
             automated_report: auto_report
    end

    before { run(instance.identifier) }

    context 'only subject with admin access level' do
      let(:user) { create :subject, :authorized, permission: 'admin:*' }

      it 'should render the template' do
        data = JSON.parse(assigns[:data], symbolize_names: true)
        template = get_tamplate_name('SubscriberRegistrationsReport')

        expect(response).to have_http_status(:ok)
        expect(response).to render_template('automated_report_instances/show')
        expect(assigns[:data]).to be_a(String)
        expect(data[:type]).to eq(template)
      end

      it 'can view this report' do
        expect(assigns[:instance]).to eq(instance)
      end
    end

    context 'subject without admin access level' do
      it 'cannot view this report' do
        expect(assigns[:instance]).to be_nil
      end
    end
  end

  context 'Subscriber Registrations Reports' do
    targets = %w(identity_providers service_providers
                 organizations rapid_connect_services services)

    targets.each do |target|
      let(:target) { target }

      it_behaves_like 'Automated Subscriber Registrations Report'
    end
  end
end
