require 'rails_helper'

RSpec.describe IdentityProviderDestinationServicesReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'identity-provider-destination-services-report' }
  let(:header) { [['Name']] }
  let(:title) { 'IdP Destination Report for' }

  let(:start) { 10.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:idp) { create :identity_provider }

  subject do
    IdentityProviderDestinationServicesReport.new(idp.entity_id, start, finish)
  end

  let(:report) { subject.generate }

  context 'IdP Destination Report' do
    it 'output should include :type, :title, :header and :footer' do
      output_title = "#{title} #{idp.name}"
      expect(report).to include(type: type,
                                title: output_title, header: header)
    end
  end
end
