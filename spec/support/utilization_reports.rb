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
      expect(report).to include(type: type, title: output_title, header: header)
    end
  end

  context '#Generate' do
    let(:counts) do
      objects.each_with_object({}) { |e, a| e[a.id] = rand(1..10) }
    end

    def create_events(objects, start, finish)
      objects.each_with_object({}) do |o, a|
        events = Array.new(rand(1..5)) do
          time = Time.at(rand(start.to_i..finish.to_i)).utc
          create_event(time, o.entity_id)
        end

        a[o.id] = events.length
      end
    end

    let!(:included_object_event_counts) do
      create_events(included_objects, start, finish)
    end

    let!(:before_object_event_counts) do
      create_events(before_objects, 1.week.until(start), start)
    end

    let!(:after_object_event_counts) do
      create_events(after_objects, finish, 1.week.since(finish))
    end

    it 'should render a report row' do
      expected = included_objects.map do |o|
        [o.name, included_object_event_counts[o.id].to_s]
      end

      expect(report[:rows]).to match_array(expected)
    end

    it 'sorts the rows in name order' do
      names = report[:rows].map(&:first)
      expect(names).to eq(names.sort_by(&:downcase))
    end

    context 'with random case permutations' do
      before do
        objects.each do |o|
          o.update!(name: o.name.send(%i[upcase downcase].sample))
        end
      end

      it 'sorts the rows in name order' do
        names = report[:rows].map(&:first)
        expect(names).to eq(names.sort_by(&:downcase))
      end
    end
  end
end
