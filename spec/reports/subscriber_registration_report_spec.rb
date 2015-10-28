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
end
