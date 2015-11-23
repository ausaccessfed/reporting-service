class ServiceCompatibilityReport < TabularReport
  report_type 'service-compatibility'
  header %w(Name Required Optional Compatible)
  footer

  def initialize(name)
    super(name)
  end

  def rows
    [%w(name 2 1 yes)]
  end
end
