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
    objects = select_activated_subscribers.sort_by { |o| o.name.downcase }

    objects.map do |o|
      rego_date = o.activations.map(&:activated_at).min

      [o.name, rego_date]
    end
  end

  private

  def select_activated_subscribers
    objects = { 'organizations' => [Organization],
                'identity_providers' => [IdentityProvider],
                'service_providers' => [ServiceProvider],
                'rapid_connect_services' => [RapidConnectService],
                'services' => [ServiceProvider, RapidConnectService] }
    fail('Identifier is not valid!') unless objects.key?(@identifier)

    objects[@identifier].flat_map do |o|
      o.joins(:activations).preload(:activations)
        .where(activations: { deactivated_at: nil })
    end
  end

  def standard_title(prefix)
    prefix.strip.downcase.titleize + ' ' + @identifier.strip.downcase.titleize
  end
end
