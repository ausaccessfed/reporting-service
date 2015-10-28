class SubscriberRegistrationReport < TabularReport
  report_type 'subscriber-registrations'
  header ['Name', 'Registration Date']
  footer

  def initialize(identifier)
    @identifier = identifier
    title = standard_title('Registered')
    super(title)
  end

  def rows
    select_activated_subscribers.map do |i|
      rego_date = i.activations.order(activated_at: :asc).first.activated_at
      [i.name, rego_date]
    end
  end

  def subscribers_list
    objects = { 'organizations' => [Organization],
                'identity_providers' => [IdentityProvider],
                'service_providers' => [ServiceProvider],
                'rapid_connect_services' => [RapidConnectService],
                'services' => [ServiceProvider, RapidConnectService] }
    objects[@identifier].flat_map(&:all).sort_by(&:name)
  end

  def select_activated_subscribers
    subscribers_list.select do |i|
      i.activations.select(&:deactivated_at) == []
    end
  end

  def standard_title(prefix)
    prefix.strip.downcase.titleize + ' ' + @identifier.strip.downcase.titleize
  end
end
