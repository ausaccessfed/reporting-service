class FederationGrowthReport < TimeSeriesReport
  report_type 'federation-growth-report'

  y_label ''

  series organizations: 'Organizations',
         identity_providers: 'Identity Providers',
         service_providers: 'Service Providers',
         rapid_connect_services: 'Rapid Connect Services'

  units ''

  def initialize(title, start, finish)
    super(title, start, finish)
    @start = start
    @finish = finish
  end

  private

  def range
    start = @start.beginning_of_day
    finish = @finish.beginning_of_day
    (0..(finish.to_i - start.to_i)).step(1.day)
  end

  def data
    activations = Activation.where('activated_at <= ?', @finish)

    range.each_with_object(organizations: [], identity_providers: [],
                           service_providers: [], rapid_connect_services: []
                          ) do |seconds, data|
      objects_count = active_objects seconds, activations
      objects_count.each do |a|
        data[DATA_SERIES[a[0]]] << [seconds, a[1]]
      end
    end
  end

  def active_objects(seconds, activations)
    objects = activations.select do |a|
      a.activated_at <= @start + seconds && a.deactivated_at.nil?
    end

    objects.group_by(&:federation_object_type)
      .transform_values { |array| array.uniq(&:federation_object_id).count }
  end

  DATA_SERIES = { 'Organization' => :organizations,
                  'IdentityProvider' => :identity_providers,
                  'ServiceProvider' => :service_providers,
                  'RapidConnectService' => :rapid_connect_services }
end
