class FederationGrowthReport < TimeSeriesReport
  report_type 'federation-growth-report'

  y_label ''

  series organizations: 'Organizations',
         identity_providers: 'Identity Providers',
         services: 'Services'

  units ''

  def initialize(title, start, finish)
    super(title, start, finish)
    @start = start
    @finish = finish
  end

  private

  def range
    start = @start.beginning_of_day
    finish = @finish.beginning_of_day
    (0..(finish.to_i - start.to_i)).step(1.day)
  end

  def data
    range.each_with_object(organizations: [], identity_providers: [],
                           services: []) do |time, data|
      data[:organizations] << [time, 1, 1]
      data[:identity_providers] << [time, 1, 1]
      data[:services] << [time, 1, 1]
    end
  end
end
