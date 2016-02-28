require 'rails_helper'

RSpec.shared_context 'Utilization Report' do
  around { |spec| Timecop.freeze { spec.run } }

  let!(:start) { 10.days.ago.beginning_of_day }
  let!(:finish) { 1.day.ago.beginning_of_day }

  let(:header) { [%w(Name Sessions)] }

  let(:obj_01) { create object_type }
  let(:obj_02) { create object_type }
  let(:obj_03) { create object_type }
  let(:obj_04) { create object_type }

  let(:report) { subject.generate }

  context 'a utilization report' do
    let(:report) { subject.generate }

    it 'must contain type, header, title' do
      expect(report).to include(type: type, title: title, header: header)
    end
  end

  context '#Generate' do
    before do
      create_list :discovery_service_event, 5, :response,
                  target => obj_01.entity_id,
                  timestamp: start

      create_list :discovery_service_event, 5, :response,
                  target => obj_02.entity_id,
                  timestamp: start + 4.days

      create_list :discovery_service_event, 5, :response,
                  target => obj_03.entity_id,
                  timestamp: start - 2.days

      create_list :discovery_service_event, 5, :response,
                  target => obj_04.entity_id,
                  timestamp: finish + 1.minute
    end

    it 'should render a report row' do
      name_01 = obj_01.name
      name_02 = obj_02.name
      name_03 = obj_03.name
      name_04 = obj_04.name

      expect(report[:rows]).to include([name_01, '5'])
      expect(report[:rows]).to include([name_02, '5'])
      expect(report[:rows]).not_to include([name_03, anything])
      expect(report[:rows]).not_to include([name_04, anything])
    end
  end
end
