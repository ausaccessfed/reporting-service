class UpdateFromFederationRegistry
  def perform
    each_fr_object(:organizations, 'organizations') do |org_data|
      org = sync_organization(org_data)

      sync_identity_providers(org)
      sync_service_providers(org)
    end
  end

  private

  def sync_identity_providers(org)
    each_fr_object(:identity_providers, 'identityproviders') do |idp_data|
      next unless org_identifier(idp_data[:organization][:id]) == org.identifier

      sync_saml_entity(org, IdentityProvider, idp_data)
    end
  end

  def sync_service_providers(org)
    each_fr_object(:service_providers, 'serviceproviders') do |sp_data|
      next unless org_identifier(sp_data[:organization][:id]) == org.identifier

      sync_saml_entity(org, ServiceProvider, sp_data)
    end
  end

  def org_identifier(fr_id)
    digest = OpenSSL::Digest::SHA256.new.digest("aaf:subscriber:#{fr_id}")
    Base64.urlsafe_encode64(digest, padding: false)
  end

  def each_fr_object(sym, path)
    data = fr_data("/federationregistry/export/#{path}")
    data[sym].each { |o| yield o }
  end

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
    configuration.federationregistry
  end

  def configuration
    Rails.application.config.reporting_service
  end

  def sync_organization(org_data)
    identifier = org_identifier(org_data[:id])
    sync_object(Organization, org_data, { identifier: identifier },
                name: org_data[:display_name])
  end

  def sync_saml_entity(org, klass, obj_data)
    entity_id = obj_data[:saml][:entity][:entity_id]
    sync_object(klass, obj_data, { entity_id: entity_id },
                name: obj_data[:display_name], organization: org)
  end

  def sync_object(klass, obj_data, identifying_attr, attrs)
    obj = klass.find_or_initialize_by(identifying_attr)
    obj.update!(attrs)

    activate_object(obj, obj_data)

    obj
  end

  def activate_object(obj, obj_data)
    activation_attrs = { activated_at: obj_data[:created_at] }

    unless obj_data[:functioning]
      activation_attrs[:deactivated_at] = obj_data[:updated_at]
    end

    obj.activations.find_or_initialize_by({}).update!(activation_attrs)
  end
end
