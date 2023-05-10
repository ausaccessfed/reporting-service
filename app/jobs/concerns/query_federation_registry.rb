# frozen_string_literal: true

require 'net/http'

module QueryFederationRegistry
  def fr_objects(sym, path)
    @fr_objects ||= {}
    @fr_objects[sym] ||= fr_data("/federationregistry/export/#{path}")
    Enumerator.new { |y| @fr_objects[sym][sym].each { |o| y << o } }
  end

  def org_identifier(fr_id)
    digest = OpenSSL::Digest.new('SHA256').digest("aaf:subscriber:#{fr_id}")
    Base64.urlsafe_encode64(digest, padding: false)
  end

  private

  def fr_data(endpoint)
    req = Net::HTTP::Get.new(endpoint)
    req['Authorization'] =
      %(AAF-FR-EXPORT service="reporting-service", key="#{fr_config[:secret]}")
    response = fr_client.request(req)
    response.value
    ImplicitSchema.new(JSON.parse(response.body.to_s, symbolize_names: true))
  end

  def fr_client
    @fr_client ||=
      Net::HTTP.new(fr_config[:host], 443).tap do |http|
        http.use_ssl = true
      end
  end

  def fr_config
    configuration.federation_registry
  end

  def configuration
    Rails.application.config.reporting_service
  end
end
