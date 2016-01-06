require 'rails_helper'

RSpec.describe ServiceProviderSourceIdentityProviderReport do
  around { |spec| Timecop.freeze { spec.run } }

  let(:type) { 'service-provider-source-identity-providers' }
  let(:header) { [['IdP Name', 'Total']] }
  let(:title) { 'SP Source Identity Provider Report for' }

  let(:start) { 11.days.ago.beginning_of_day }
  let(:finish) { Time.zone.now.end_of_day }

  let(:sp) { create :service_provider }

  subject do
    ServiceProviderSourceIdentityProviderReport.new(sp.entity_id, start, finish)
  end

  let(:report) { subject.generate }

  context 'SP Source IdPs Report' do
    it 'output should include :type, :title, :header and :footer' do
      output_title = "#{title} #{sp.name}"
      expect(report).to include(type: type,
                                title: output_title, header: header)
    end
  end
end
