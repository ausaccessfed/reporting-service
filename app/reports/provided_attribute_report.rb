class ProvidedAttributeReport < TabularReport
  report_type 'provided-attribute-report'
  header %w(Name Supported)
  footer

  def rows
    [%w(name yes)]
  end
end
