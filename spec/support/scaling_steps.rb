# frozen_string_literal: true

RSpec.shared_examples 'report with scalable steps' do
  around { |spec| Timecop.freeze { spec.run } }

  let(:range_less_than_month) do
    { start: Time.now.utc - 2.weeks, end: Time.now.utc }
  end

  let(:range_less_than_month_02) do
    { start: Time.now.utc - 2.days, end: Time.now.utc }
  end

  let(:range_1_month) do
    { start: Time.now.utc - 1.month, end: Time.now.utc }
  end

  let(:range_1_month_february_exception) do
    {
      start: Time.parse('2017-02-09 00:00:00').utc,
      end: Time.parse('2017-03-09 00:00:00').utc
    }
  end

  let(:range_2_months_february_exception) do
    {
      start: Time.parse('2017-01-09 00:00:00').utc,
      end: Time.parse('2017-03-09 00:00:00').utc
    }
  end

  let(:range_3_months_february_exception) do
    {
      start: Time.parse('2017-01-09 00:00:00').utc,
      end: Time.parse('2017-04-09 00:00:00').utc
    }
  end

  let(:range_3_months_across_year_end_february_exception) do
    {
      start: Time.parse('2016-12-09 00:00:00').utc,
      end: Time.parse('2017-03-09 00:00:00').utc
    }
  end

  let(:range_2_months) do
    { start: Time.now.utc - 2.months, end: Time.now.utc }
  end

  let(:range_3_months) do
    { start: Time.now.utc - 3.months, end: Time.now.utc }
  end

  let(:range_4_months) do
    { start: Time.now.utc - 4.months, end: Time.now.utc }
  end

  let(:range_6_months) do
    { start: Time.now.utc - 6.months, end: Time.now.utc }
  end

  let(:range_7_months) do
    { start: Time.now.utc - 7.months, end: Time.now.utc }
  end

  let(:range_9_months) do
    { start: Time.now.utc - 9.months, end: Time.now.utc }
  end

  let(:range_1_year) do
    { start: Time.now.utc - 1.year, end: Time.now.utc }
  end

  let(:range_1_year_3_months) do
    { start: Time.now.utc - (1.year + 3.months), end: Time.now.utc }
  end

  let(:range_2_year_2_months) do
    { start: Time.now.utc - (2.years + 2.months), end: Time.now.utc }
  end

  it 'Steps when blank' do
    post path, params: params.merge({ start: nil, end: nil })

    expect(assigns[:data]).to be_nil
  end

  it 'Steps should be 1 hour within less than a month' do
    [range_less_than_month, range_less_than_month_02].each do |rng|
      post path, params: params.merge(rng)

      data = JSON.parse(assigns[:data], symbolize_names: true)
      sessions = data[:data][:sessions]

      expect(sessions[1]).to eq([3600, 0.0])
      expect(sessions[2]).to eq([3600 * 2, 0.0])
    end
  end

  context 'Steps should be 2 hours within 1 to 3 months' do
    it 'behaves correctly for 30+ day months' do
      [range_1_month, range_2_months].each do |rng|
        post path, params: params.merge(rng)

        data = JSON.parse(assigns[:data], symbolize_names: true)
        sessions = data[:data][:sessions]

        expect(sessions[1]).to eq([7200, 0.0])
        expect(sessions[2]).to eq([7200 * 2, 0.0])
      end
    end

    it 'behaves correctly when the time range spans February' do
      [
        range_1_month_february_exception,
        range_2_months_february_exception
      ].each do |rng|
        post path, params: params.merge(rng)

        data = JSON.parse(assigns[:data], symbolize_names: true)
        sessions = data[:data][:sessions]

        expect(sessions[1]).to eq([7200, 0.0])
        expect(sessions[2]).to eq([7200 * 2, 0.0])
      end
    end
  end

  context 'Steps should be 6 hours within 3 to 6 months' do
    it 'behaves correctly for 30+ day months' do
      [range_3_months, range_4_months].each do |rng|
        post path, params: params.merge(rng)

        data = JSON.parse(assigns[:data], symbolize_names: true)
        sessions = data[:data][:sessions]

        expect(sessions[1]).to eq([21_600, 0.0])
        expect(sessions[2]).to eq([21_600 * 2, 0.0])
      end
    end

    it 'behaves correctly when the time range spans February' do
      [
        range_3_months_february_exception,
        range_3_months_across_year_end_february_exception
      ].each do |rng|
        post path, params: params.merge(rng)

        data = JSON.parse(assigns[:data], symbolize_names: true)
        sessions = data[:data][:sessions]

        expect(sessions[1]).to eq([21_600, 0.0])
        expect(sessions[2]).to eq([21_600 * 2, 0.0])
      end
    end
  end

  it 'Steps should be 12 hours within 6 to 12 months' do
    [range_6_months, range_7_months, range_9_months].each do |rng|
      post path, params: params.merge(rng)

      data = JSON.parse(assigns[:data], symbolize_names: true)
      sessions = data[:data][:sessions]

      expect(sessions[1]).to eq([43_200, 0.0])
      expect(sessions[2]).to eq([43_200 * 2, 0.0])
    end
  end

  it 'Steps should be 24 hours within 1 year or more' do
    [range_1_year,
     range_1_year_3_months, range_2_year_2_months].each do |rng|
      post path, params: params.merge(rng)

      data = JSON.parse(assigns[:data], symbolize_names: true)
      sessions = data[:data][:sessions]

      expect(sessions[1]).to eq([86_400, 0.0])
      expect(sessions[2]).to eq([86_400 * 2, 0.0])
    end
  end
end
