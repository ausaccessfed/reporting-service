# frozen_string_literal: true
class UpdateFromRapidConnect
  def perform
    RapidConnectService.transaction do
      touched = []

      rapid_data[:services].each do |service_data|
        next unless service_data[:enabled]
        service = sync_service(service_data)
        sync_activations(service, service_data)
        touched << service
      end

      RapidConnectService.where.not(id: touched.map(&:id)).destroy_all
    end
  end

  private

  AUTHORIZATION_HEADER_VALUE =
    'AAF-RAPID-EXPORT service="reporting-service", key="%s"'

  def sync_service(service_data)
    org = Organization.find_by_name(service_data[:organization])
    rapid_data = service_data[:rapidconnect]

    attrs = { name: service_data[:name],
              service_type: rapid_data.fetch(:type, 'research'),
              organization: org }

    RapidConnectService.find_or_initialize_by(identifier: service_data[:id])
                       .tap { |s| s.update!(attrs) }
  end

  def sync_activations(service, service_data)
    service.activations.find_or_initialize_by({})
           .update!(activated_at: Time.zone.parse(service_data[:created_at]))
  end

  def rapid_data
    req = Net::HTTP::Get.new('/export/basic')
    req['Authorization'] = format(AUTHORIZATION_HEADER_VALUE,
                                  rapid_config[:secret])

    response = rapid_client.request(req)
    response.value
    ImplicitSchema.new(JSON.parse(response.body.to_s, symbolize_names: true))
  end

  def rapid_client
    Net::HTTP.new(rapid_config[:host], 443).tap do |http|
      http.use_ssl = true
    end
  end

  def rapid_config
    configuration.rapidconnect
  end

  def configuration
    Rails.application.config.reporting_service
  end
end
