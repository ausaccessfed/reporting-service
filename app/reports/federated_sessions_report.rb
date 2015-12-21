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
    report = average_rate sessions, @start, @steps.hours

    output_data range, report, @steps.hours, @steps
  end

  def sessions
    DiscoveryServiceEvent
      .within_range(@start, @finish).sessions.pluck(:timestamp)
  end
end
