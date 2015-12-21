class FederatedSessionsReport < TimeSeriesReport
  report_type 'federated-sessions'

  y_label ''

  series sessions: 'Rate/h'

  units ''

  def initialize(start, finish, steps)
    title = 'Federated Sessions'

    super(title, start: start, end: finish)
    @start = start
    @finish = finish
    @steps = steps
  end

  private

  prepend Data::ReportData

  def range
    (0..(@finish - @start).to_i)
  end

  def data
    output_data range, @steps.hours, @steps
  end

  def sessions
    DiscoveryServiceEvent.within_range(@start, @finish).sessions
  end

  def average_rate(sessions)
    sessions.each_with_object({}) do |session, data|
      offset = session - @start
      point = offset - (offset % @steps.hours)
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end
end
