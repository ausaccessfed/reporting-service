# frozen_string_literal: true
class SubscriberRegistrationsReport < TabularReport
  report_type 'subscriber-registrations'
  header %w(Name Registration\ Date)
  footer

  def initialize(identifier)
    @identifier = identifier
    title = standard_title('Registered')

    super(title)
  end

  private

  def rows
    objects = select_activated_subscribers.sort_by { |o| o.name.downcase }

    objects.map do |o|
      registration_date = o.activations.map(&:activated_at).min

      [o.name, registration_date.xmlschema]
    end
  end

  def select_activated_subscribers
    objects = { 'organizations' => [Organization],
                'identity_providers' => [IdentityProvider],
                'service_providers' => [ServiceProvider],
                'rapid_connect_services' => [RapidConnectService],
                'services' => [ServiceProvider, RapidConnectService] }
    fail('Identifier is not valid!') unless objects.key?(@identifier)

    objects[@identifier].flat_map(&:active)
  end

  def standard_title(prefix)
    prefix.strip.downcase.titleize + ' ' + @identifier.strip.downcase.titleize
  end
end
