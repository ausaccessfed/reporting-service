require 'rails_helper'

RSpec.describe FederationGrowthReport do
  let(:title) { 'title' }
  let(:units) { '' }
  let(:labels) do
    { y: '', organizations: 'Organizations',
      identity_providers: 'Identity Providers',
      rapid_connect_services: 'Rapid Connect Services' }
  end

  subject { FederationGrowthReport.new(title, start, finish) }

  context 'growth report generate' do
    let(:start) { Time.zone.today - 10.days }
    let(:finish) { Time.zone.today }
    let(:range) { { start: start.xmlschema, end: finish.xmlschema } }
    it 'includes title, units, lables and range' do
      expect(subject.generate).to include(title: title, units: units,
                                          labels: labels, range: range)
    end
  end
end
