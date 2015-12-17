class IdentityProviderSessionsReport < TimeSeriesReport
  report_type 'identity-provider-sessions'

  y_label ''

  series sessions: 'sessions'

  units ''

  def initialize(start, finish)
    title = 'Identity Provider Sessions'

    super(title, start: start, end: finish)
  end

  private

  def data
    { sessions: [[1, 0]] }
  end
end
