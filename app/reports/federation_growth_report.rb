class FederationGrowthReport < TimeSeriesReport
  report_type 'federation-growth-report'

  y_label ''

  series organizations: 'Organizations',
         identity_providers: 'Identity Providers',
         services: 'Services'

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
                           services: []
                          ) do |seconds, data|
      objects_count = active_objects seconds, activations
      objects_count.each do |k, v|
        data[DATA_SERIES[k]] << [seconds, v]
      end
    end
  end

  def active_objects(seconds, activations)
    timestamp = @start + seconds

    objects = activations.select do |o|
      o.activated_at <= timestamp &&
      (o.deactivated_at.nil? || o.deactivated_at > timestamp)
    end

    objects.group_by(&:federation_object_type)
      .transform_values { |array| array.uniq(&:federation_object_id).count }
  end

  DATA_SERIES = { 'Organization' => :organizations,
                  'IdentityProvider' => :identity_providers,
                  'ServiceProvider' => :services,
                  'RapidConnectService' => :services }
end
