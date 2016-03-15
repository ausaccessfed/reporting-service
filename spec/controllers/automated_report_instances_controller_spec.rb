require 'rails_helper'

RSpec.describe AutomatedReportInstancesController, type: :controller do
  let(:organization) { create :organization }
  let(:attribute) { create :saml_attribute }
  let(:sp) { create :service_provider, organization: organization }
  let(:unknown_sp) { create :service_provider }
  let(:idp) { create :identity_provider, organization: organization }
  let(:unknown_idp) { create :identity_provider }

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
    let(:user) { create :subject }

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
    end
  end

  context 'Federation Growth Report' do
    let(:report_class) { 'FederationGrowthReport' }
    let(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  context 'Federated Sessions Report' do
    let(:report_class) { 'FederatedSessionsReport' }
    let(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  context 'Daily Demand Report' do
    let(:report_class) { 'DailyDemandReport' }
    let(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  context 'Identity Provider Attributes Report' do
    let(:report_class) { 'IdentityProviderAttributesReport' }
    let(:target) { nil }

    it_behaves_like 'Automated Public Report'
  end

  context 'Provided Attribute Report Report' do
    let(:report_class) { 'ProvidedAttributeReport' }
    let(:target) { attribute.name }

    it_behaves_like 'Automated Public Report'
  end

  context 'Requested Attribute Report' do
    let(:report_class) { 'RequestedAttributeReport' }
    let(:target) { attribute.name }

    it_behaves_like 'Automated Public Report'
  end

  context 'Automated Federation Service Compatibility Report' do
    let(:target) { sp.entity_id }
    let(:report_class) { 'ServiceCompatibilityReport' }

    it_behaves_like 'Automated Public Report'
  end

  shared_examples 'Automated Subscriber Report' do
    let(:auto_report) do
      create :automated_report,
             target: object.entity_id,
             report_class: report_class
    end

    let!(:instance) do
      create :automated_report_instance,
             automated_report: auto_report
    end

    let!(:unknown_auto_report) do
      create :automated_report,
             target: unknown_object.entity_id,
             report_class: report_class
    end

    let!(:unknown_instance) do
      create :automated_report_instance,
             automated_report: unknown_auto_report
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
        run(unknown_instance.identifier)

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
      let(:user) { create :subject, :authorized, permission: '*' }

      it 'should be able to view all types of reports' do
        run(instance.identifier)
        expect(assigns[:instance]).to eq(instance)

        run(unknown_instance.identifier)
        expect(assigns[:instance]).to eq(unknown_instance)
      end
    end
  end

  context 'Identity Provider Sessions Report' do
    let(:report_class) { 'IdentityProviderSessionsReport' }
    let(:object) { idp }
    let(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Identity Provider Daily Demand Report' do
    let(:report_class) { 'IdentityProviderDailyDemandReport' }
    let(:object) { idp }
    let(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Identity Provider Destination Services Report' do
    let(:report_class) { 'IdentityProviderDestinationServicesReport' }
    let(:object) { idp }
    let(:unknown_object) { unknown_idp }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Service Provider Sessions Report' do
    let(:report_class) { 'ServiceProviderSessionsReport' }
    let(:object) { sp }
    let(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Service Provider Daily Demand Report' do
    let(:report_class) { 'ServiceProviderDailyDemandReport' }
    let(:object) { sp }
    let(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
  end

  context 'Service Provider Source Identity Providers Report' do
    let(:report_class) { 'ServiceProviderSourceIdentityProvidersReport' }
    let(:object) { sp }
    let(:unknown_object) { unknown_sp }

    it_behaves_like 'Automated Subscriber Report'
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
      let(:user) { create :subject, :authorized, permission: '*' }

      it 'should render the template' do
        run(instance.identifier)

        data = JSON.parse(assigns[:data], symbolize_names: true)

        expect(response).to have_http_status(:ok)
        expect(response).to render_template('automated_report_instances/show')
        expect(assigns[:data]).to be_a(String)
        expect(data[:type]).to eq('subscriber-registrations')
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
