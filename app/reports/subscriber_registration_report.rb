class SubscriberRegistrationReport < TabularReport
  report_type 'subscriber-registrations'
  header ['Name', 'Registration Date']
  footer ['Name', 'Registration Date']

  def initialize(title, indentifier)
    super(title)
    @identifier = indentifier
  end

  def rows
    select_activated_subscribers.map do |i|
      rego_date = i.activations.order(activated_at: :asc).first.activated_at
      [i.name, rego_date]
    end
  end

  # rubocop:disable Metrics/MethodLength
  def subscribers_list
    case @identifier
    when 'organizations'
      Organization.all
    when 'identity_providers'
      IdentityProvider.all
    when 'service_providers'
      ServiceProvider.all
    when 'rapid_connect_services'
      RapidConnectService.all
    when 'services'
      ServiceProvider.all + RapidConnectService.all
    end
  end

  def select_activated_subscribers
    subscribers_list.select do |i|
      i.activations.select(&:deactivated_at) == []
    end
  end
end
