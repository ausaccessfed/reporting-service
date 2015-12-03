class FederatedSessionsReport < TimeSeriesReport
  report_type 'federated-sessions'

  y_label ''

  series sessions: 'Rate/m'

  units ''

  def initialize(start, finish)
    title = 'Federated Sessions'

    super(title, start, finish)
    @start = start
    @finish = finish
  end

  private

  def data
    { sessions: (1..10).map { |t| [t, 1] } }
  end
end
