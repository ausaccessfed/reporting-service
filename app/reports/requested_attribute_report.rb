class RequestedAttributeReport < TabularReport
  report_type 'requested-attribute'
  header %w(Name Status)
  footer

  def initialize(name)
    title = "Service Providers requesting #{name}"
    super(title)
  end

  def rows
    [%w(1, 2)]
  end
end
