class FederatedSessionsReport < TimeSeriesReport
  prepend TimeSeriesSharedMethods

  report_type 'federated-sessions'
  y_label ''
  units ''
  series sessions: 'Rate/h'

  def initialize(start, finish, steps)
    title = 'Federated Sessions'
    @start = start
    @finish = finish
    @steps = steps

    super(title, start: @start, end: @finish)
  end

  private

  def data
    per_hour_output
  end
end
