require 'rails_helper'

RSpec.describe FederationGrowthReport do
  let(:title) { 'title' }
  let(:units) { '' }
  let(:labels) do
    { y: '', organizations: 'Organizations',
      identity_providers: 'Identity Providers',
      services: 'Services' }
  end

  let!(:start) { Time.zone.now - 1.week }
  let!(:finish) { Time.zone.now }
  let!(:range) { { start: start.xmlschema, end: finish.xmlschema } }

  subject { FederationGrowthReport.new(title, start, finish) }

  context '#generate report' do
    let(:report) { subject.generate }

    it 'must include series ' do
      expect(report).to include(title: title, units: units,
                                labels: labels, range: range)
    end

    it 'output structure should match stacked_report' do
      [:organizations,
       :identity_providers, :services].each do |type|
        report[:data][type].each { |i| expect(i.count).to eq(3) }
      end
    end
  end
end
