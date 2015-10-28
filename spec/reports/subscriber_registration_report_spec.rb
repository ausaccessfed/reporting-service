require 'rails_helper'

RSpec.describe SubscriberRegistrationReport do
  let(:title) { Faker::Lorem.sentence }
  let(:header) { [['Name', 'Registration Date']] }
  let(:footer) { [['Name', 'Registration Date']] }
  let(:type) { 'subscriber-registrations' }

  let(:org_report) do
    SubscriberRegistrationReport.new(title, 'organizations')
  end

  let(:idp_report) do
    SubscriberRegistrationReport.new(title, 'identity_providers')
  end

  let(:sp_report) do
    SubscriberRegistrationReport.new(title, 'service_providers')
  end

  let(:rapid_c_report) do
    SubscriberRegistrationReport.new(title, 'rapid_connect_services')
  end

  context '#generate' do
    it 'must have title, header and type' do
      expect(org_report.generate).to include(title: title, header: header,
                                             footer: footer, type: type)
    end

    it 'must have title, header and type' do
      expect(idp_report.generate).to include(title: title, header: header,
                                             footer: footer, type: type)
    end

    it 'must have title, header and type' do
      expect(sp_report.generate).to include(title: title, header: header,
                                            footer: footer, type: type)
    end

    it 'must have title, header and type' do
      expect(rapid_c_report.generate).to include(title: title, header: header,
                                                 footer: footer, type: type)
    end
  end

  context '#subscribers_list' do
    it 'should to match Organization.all' do
      expect(org_report.subscribers_list)
        .to match_array(Organization.all)
    end

    it 'should to match IdentityProvider.all' do
      expect(idp_report.subscribers_list)
        .to match_array(IdentityProvider.all)
    end

    it 'should to match ServiceProvider.all' do
      expect(sp_report.subscribers_list)
        .to match_array(ServiceProvider.all)
    end

    it 'should to match RapidConnectService.all' do
      expect(rapid_c_report.subscribers_list)
        .to match_array(RapidConnectService.all)
    end
  end
end
