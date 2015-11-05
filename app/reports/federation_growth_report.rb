class FederationGrowthReport < TimeSeriesReport
  report_type 'federation-growth-report'

  y_label ''

  series organizations: 'Organizations',
         identity_providers: 'Identity Providers',
         rapid_connect_services: 'Rapid Connect Services'

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
                           rapid_connect_services: []) do |point, data|
      # TODO
      data[:organizations] << [point, 0]
      data[:identity_providers] << [point, 0]
      data[:rapid_connect_services] << [point, 0]
    end
  end
end
