class FederatedSessionsReport < TimeSeriesReport
  report_type 'federated-sessions'

  y_label ''

  series sessions: 'Rate/m'

  units ''

  def initialize(start, finish, steps)
    title = 'Federated Sessions'

    super(title, start, finish)
    @start = start
    @finish = finish
    @steps = steps.to_f.round(2)
  end

  private

  def range
    start = @start
    finish = @finish
    (0..(finish.to_i - start.to_i)).step(@steps.minutes)
  end

  def data
    { sessions: range.map { |t| [t, 1] } }
  end
end
