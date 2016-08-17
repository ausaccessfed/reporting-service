# frozen_string_literal: true
module Authentication
  module IdentityEnhancement
    def update_roles(subject)
      subject.entitlements = entitlements(subject.shared_token)
    end

    private

    def entitlements(shared_token)
      data = ide_data(shared_token)

      values = data[:attributes].map do |a|
        next if a[:name] != 'eduPersonEntitlement'
        a[:value]
      end

      values.compact
    end

    def ide_data(shared_token)
      uri = ide_uri(shared_token)
      req = Net::HTTP::Get.new(uri)

      with_ide_client(uri) do |http|
        response = http.request(req)
        response.value # Raise exception on HTTP error
        JSON.parse(response.body, symbolize_names: true)
      end
    rescue Net::HTTPServerException => e
      raise unless e.data.is_a?(Net::HTTPNotFound)
      { attributes: [] }
    end

    def ide_uri(shared_token)
      host = ide_config[:host]
      URI.parse("https://#{host}/api/subjects/#{shared_token}/attributes")
    end

    def with_ide_client(uri)
      client = Net::HTTP.new(uri.host, uri.port)

      client.use_ssl = true
      client.cert = ide_cert
      client.key = ide_key
      client.verify_mode = OpenSSL::SSL::VERIFY_PEER

      client.start { |http| yield http }
    end

    def ide_cert
      cert = File.read(ide_config[:cert])
      OpenSSL::X509::Certificate.new(cert)
    end

    def ide_key
      key = File.read(ide_config[:key])
      OpenSSL::PKey::RSA.new(key)
    end

    def ide_config
      Rails.application.config.reporting_service.ide
    end
  end
end
