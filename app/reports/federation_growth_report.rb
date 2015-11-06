class FederationGrowthReport < TimeSeriesReport
  report_type 'federation-growth-report'

  y_label ''

  series organizations: 'Organizations',
         identity_providers: 'Identity Providers',
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
                           rapid_connect_services: []) do |point, data|
      acts = activations_in_range point, activations
      acts.each do |a|
        data[object_switcher[a[0]]] << [point, a[1]]
      end
    end
  end

  def activations_in_range(point, activations)
    acts = activations.select do |a|
      a.activated_at <= @start + point && a.deactivated_at.nil?
    end

    acts.group_by(&:federation_object_type).map do |type, value|
      value.uniq! { |o| o[:federation_object_id] }
      [type, value.count]
    end
  end

  def object_switcher
    { 'Organization' => :organizations,
      'IdentityProvider' => :identity_providers,
      'RapidConnectService' => :rapid_connect_services }
  end
end
