class FederatedSessionsReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

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
    output_data
  end
end
