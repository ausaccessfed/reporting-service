# frozen_string_literal: true

RSpec.shared_context 'Utilization Report' do
  around { |spec| Timecop.freeze { spec.run } }

  let!(:start) { 10.days.ago.beginning_of_day }
  let!(:finish) { 1.day.ago.beginning_of_day }
  let(:header) { [%w[Name Sessions]] }

  let(:included_objects) { create_list(object_type, rand(4..7)) }
  let(:before_objects) { create_list(object_type, rand(1..3)) }
  let(:after_objects) { create_list(object_type, rand(1..3)) }
  let(:objects) { included_objects + before_objects + after_objects }
  let(:report) { subject.generate }

  context 'a utilization report' do
    it 'must contain type, header, title' do
      expect(report).to include(type:, title: output_title, header:)
    end
  end

  describe '#Generate' do
    let(:counts) { objects.each_with_object({}) { |e, a| e[a.id] = rand(1..10) } }
    let!(:included_object_event_counts) { create_events(included_objects, start, finish) }
    let!(:before_object_event_counts) { create_events(before_objects, 1.week.until(start), start) }
    let!(:after_object_event_counts) { create_events(after_objects, finish, 1.week.since(finish)) }

    def create_events(objects, start, finish)
      objects.each_with_object({}) do |o, a|
        events =
          Array.new(rand(1..5)) do
            time = Time.at(rand(start.to_i..finish.to_i)).utc
            create_event(time, o.entity_id)
          end

        a[o.id] = events.length
      end
    end

    it 'renders a report row' do
      expected = included_objects.map { |o| [o.name, included_object_event_counts[o.id].to_s] }

      expect(report[:rows]).to match_array(expected)
    end

    it 'sorts the rows in name order' do
      names = report[:rows].map(&:first)
      expect(names).to eq(names.sort_by(&:downcase))
    end

    context 'with random case permutations' do
      let(:samples) { %i[upcase downcase].sample }

      before { objects.each { |o| o.update!(name: o.name.send(samples)) } }

      it 'sorts the rows in name order' do
        names = report[:rows].map(&:first)
        expect(names).to eq(names.sort_by(&:downcase))
      end
    end
  end
end
