require 'rails_helper'

RSpec.describe AutomatedReportInstance, type: :model do
  around { |spec| Timecop.freeze { spec.run } }

  subject { build(:automated_report_instance) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:automated_report) }
    it { is_expected.to validate_presence_of(:range_start) }

    it 'requires a UTC timestamp with time set to 00:00:00' do
      time = Time.zone.parse('2015-01-01T00:00:00Z')
      expect(subject).to allow_value(time).for(:range_start)

      zone = Time.find_zone('Australia/Brisbane')

      time = zone.parse('2015-01-01T00:00:00+10:00')
      expect(subject).not_to allow_value(time).for(:range_start)

      # Time zone conversation happens implicitly
      time = zone.parse('2015-01-01T10:00:00+10:00')
      expect(subject).to allow_value(time).for(:range_start)
    end
  end

  describe '#materialize' do
    let(:automated_report) do
      create(:automated_report,
             report_class: report_class, target: target, interval: interval)
    end

    subject do
      create(:automated_report_instance,
             automated_report: automated_report,
             range_start: range_start)
    end

    let(:report) { subject.materialize }
    let(:target) { nil }

    shared_examples 'an instantiated report' do |kind, range: false|
      context "a #{kind} report" do
        let(:interval) { 'monthly' }
        let(:range_start) { 1.month.ago.utc.beginning_of_month }

        it 'creates the report instance' do
          expect(report.class.name).to eq(automated_report.report_class)
          expect(report.generate[:type]).to eq(kind)
        end

        if range
          let(:expected_range) do
            {
              start: range_start.xmlschema,
              end: Time.now.utc.beginning_of_month.xmlschema
            }
          end

          context 'for a monthly report' do
            it 'sets the correct range' do
              expect(report.generate[:range]).to eq(expected_range)
            end
          end

          context 'for a quarterly report' do
            let(:interval) { 'quarterly' }
            let(:range_start) { 3.months.ago.utc.beginning_of_month }

            it 'sets the correct range' do
              expect(report.generate[:range]).to eq(expected_range)
            end
          end

          context 'for a yearly report' do
            let(:interval) { 'yearly' }
            let(:range_start) { 12.months.ago.utc.beginning_of_month }

            it 'sets the correct range' do
              expect(report.generate[:range]).to eq(expected_range)
            end
          end
        else
          it 'has no range' do
            expect(report.generate).not_to have_key(:range)
          end
        end
      end
    end

    it_behaves_like 'an instantiated report', 'federation-growth',
                    range: true do
      let(:report_class) { 'FederationGrowthReport' }
    end

    it_behaves_like 'an instantiated report', 'daily-demand',
                    range: true do
      let(:report_class) { 'DailyDemandReport' }
    end

    it_behaves_like 'an instantiated report', 'federated-sessions',
                    range: true do
      let(:report_class) { 'FederatedSessionsReport' }
    end

    it_behaves_like 'an instantiated report', 'subscriber-registrations' do
      let(:target) { 'organizations' }
      let(:report_class) { 'SubscriberRegistrationReport' }
    end

    it_behaves_like 'an instantiated report', 'identity-provider-attributes' do
      let(:report_class) { 'IdentityProviderAttributesReport' }
    end

    it_behaves_like 'an instantiated report',
                    'identity-provider-daily-demand' do
      let(:target) { create(:identity_provider).entity_id }
      let(:report_class) { 'IdentityProviderDailyDemandReport' }
    end

    it_behaves_like 'an instantiated report',
                    'identity-provider-destination-services' do
      let(:target) { create(:identity_provider).entity_id }
      let(:report_class) { 'IdentityProviderDestinationServicesReport' }
    end

    it_behaves_like 'an instantiated report', 'identity-provider-sessions',
                    range: true do
      let(:target) { create(:identity_provider).entity_id }
      let(:report_class) { 'IdentityProviderSessionsReport' }
    end

    it_behaves_like 'an instantiated report', 'provided-attribute' do
      let(:target) { create(:saml_attribute).name }
      let(:report_class) { 'ProvidedAttributeReport' }
    end

    it_behaves_like 'an instantiated report', 'requested-attribute' do
      let(:target) { create(:saml_attribute).name }
      let(:report_class) { 'RequestedAttributeReport' }
    end

    it_behaves_like 'an instantiated report', 'service-compatibility' do
      let(:target) { create(:service_provider).entity_id }
      let(:report_class) { 'ServiceCompatibilityReport' }
    end

    it_behaves_like 'an instantiated report', 'service-provider-daily-demand' do
      let(:target) { create(:service_provider).entity_id }
      let(:report_class) { 'ServiceProviderDailyDemandReport' }
    end

    it_behaves_like 'an instantiated report', 'service-provider-sessions',
                    range: true do
      let(:target) { create(:service_provider).entity_id }
      let(:report_class) { 'ServiceProviderSessionsReport' }
    end

    it_behaves_like 'an instantiated report',
                    'service-provider-source-identity-providers' do
      let(:target) { create(:service_provider).entity_id }
      let(:report_class) { 'ServiceProviderSourceIdentityProvidersReport' }
    end
  end
end
