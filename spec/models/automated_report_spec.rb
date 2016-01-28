require 'rails_helper'

RSpec.describe AutomatedReport, type: :model do
  describe 'validations' do
    let(:idp) { create(:identity_provider) }
    let(:sp) { create(:service_provider) }
    let(:rapid_service) { create(:rapid_connect_service) }
    let(:attribute) { create(:saml_attribute) }

    it { is_expected.to validate_presence_of(:report_class) }
    it { is_expected.to validate_presence_of(:interval) }
    it { is_expected.not_to validate_presence_of(:target) }

    it 'requires a valid interval name' do
      expect(subject).to allow_value('monthly').for(:interval)
      expect(subject).to allow_value('quarterly').for(:interval)
      expect(subject).to allow_value('yearly').for(:interval)
      expect(subject).not_to allow_value('fortnightly').for(:interval)
    end

    it 'requires a valid report class' do
      expect(subject).to allow_value('DailyDemandReport').for(:report_class)
      expect(subject).not_to allow_value('FakeReport').for(:report_class)
      expect(subject).not_to allow_value('TabularReport').for(:report_class)
    end

    it 'requires no target for targetless reports' do
      targetless_reports = %w(
        DailyDemandReport FederatedSessionsReport FederationGrowthReport
        IdentityProviderAttributesReport
      )
      targetless_reports.each do |klass|
        subject.report_class = klass
        expect(subject).to allow_value(nil).for(:target)
        expect(subject).not_to allow_value(idp.entity_id).for(:target)
        expect(subject).not_to allow_value(sp.entity_id).for(:target)
        expect(subject).not_to allow_value(attribute.name).for(:target)
      end
    end

    it 'requires an object type identifier for object reports' do
      subject.report_class = 'SubscriberRegistrationsReport'
      types = %w(identity_providers service_providers organizations
                 rapid_connect_services services)
      types.each do |type|
        expect(subject).to allow_value(type).for(:target)
      end
      expect(subject).not_to allow_value(:object).for(:target)
    end

    it 'requires an IdP entity_id for IdP reports' do
      idp_reports = %w(
        IdentityProviderSessionsReport IdentityProviderDailyDemandReport
        IdentityProviderDestinationServicesReport
      )

      idp_reports.each do |klass|
        subject.report_class = klass
        expect(subject).to allow_value(idp.entity_id).for(:target)
        expect(subject).not_to allow_value(sp.entity_id).for(:target)
        expect(subject).not_to allow_value(attribute.name).for(:target)
        expect(subject).not_to allow_value(nil).for(:target)
      end
    end

    it 'requires an SP entity_id for SP reports' do
      sp_reports = %w(
        ServiceProviderSessionsReport ServiceProviderDailyDemandReport
        ServiceProviderSourceIdentityProvidersReport ServiceCompatibilityReport
      )
      sp_reports.each do |klass|
        subject.report_class = klass
        expect(subject).to allow_value(sp.entity_id).for(:target)
        expect(subject).not_to allow_value(idp.entity_id).for(:target)
        expect(subject).not_to allow_value(attribute.name).for(:target)
        expect(subject).not_to allow_value(nil).for(:target)
      end
    end

    it 'requires an attribute name for attribute reports' do
      %w(ProvidedAttributeReport RequestedAttributeReport).each do |klass|
        subject.report_class = klass
        expect(subject).to allow_value(attribute.name).for(:target)
        expect(subject).not_to allow_value(idp.entity_id).for(:target)
        expect(subject).not_to allow_value(sp.entity_id).for(:target)
        expect(subject).not_to allow_value(nil).for(:target)
      end
    end
  end

  describe '#interval' do
    it 'returns an ActiveSupport::StringInquirer' do
      subject.interval = 'monthly'
      expect(subject.interval).to be_an(ActiveSupport::StringInquirer)
    end

    it 'returns nil when unset' do
      subject.interval = nil
      expect(subject.interval).to be_nil
    end
  end
end
