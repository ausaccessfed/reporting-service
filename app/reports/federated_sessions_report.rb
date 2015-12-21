class FederatedSessionsReport < TimeSeriesReport
  prepend Data::ReportData

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

  def data
    report = average_rate sessions, @start, @steps.hours

    output_data range, report, @steps.hours, @steps
  end
end
