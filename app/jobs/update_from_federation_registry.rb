# frozen_string_literal: true
class UpdateFromFederationRegistry
  include QueryFederationRegistry

  def perform
    ActiveRecord::Base.transaction do
      touched = sync_attributes + sync_organizations
      clean(touched)
    end
  end

  private

  def sync_attributes
    fr_objects(:attributes, 'attributes').map do |attr_data|
      sync_attribute(attr_data)
    end
  end

  def sync_organizations
    fr_objects(:organizations, 'organizations').flat_map do |org_data|
      org = sync_organization(org_data)
      idps = sync_identity_providers(org)
      sps = sync_service_providers(org)

      [org, *idps, *sps].compact
    end
  end

  def sync_identity_providers(org)
    fr_objects(:identity_providers, 'identityproviders').flat_map do |idp_data|
      next unless org_identifier(idp_data[:organization][:id]) == org.identifier

      idp = sync_saml_entity(org, IdentityProvider, idp_data)
      attrs = sync_idp_attributes(idp, idp_data)

      attrs.unshift(idp)
    end
  end

  def sync_service_providers(org)
    fr_objects(:service_providers, 'serviceproviders').flat_map do |sp_data|
      next unless org_identifier(sp_data[:organization][:id]) == org.identifier

      sp = sync_saml_entity(org, ServiceProvider, sp_data)
      attrs = sync_sp_attributes(sp, sp_data)

      attrs.unshift(sp)
    end
  end

  def sync_attribute(attr_data)
    attribute = SAMLAttribute.find_or_initialize_by(name: attr_data[:name])
    attribute.update!(core: (attr_data[:category][:name] == 'Core'),
                      description: attr_data[:description])

    attribute
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

  def sync_idp_attributes(idp, idp_data)
    idp_data[:saml][:attributes].map do |attr_data|
      sync_saml_entity_attribute(idp.identity_provider_saml_attributes,
                                 attr_data)
    end
  end

  def sync_sp_attributes(sp, sp_data)
    sp_data[:saml][:attribute_consuming_services].flat_map do |acs|
      acs[:attributes].map do |attr_data|
        sync_saml_entity_attribute(sp.service_provider_saml_attributes,
                                   attr_data,
                                   optional: !attr_data[:is_required])
      end
    end
  end

  def sync_saml_entity_attribute(scope, attr_data, extra_attrs = {})
    attribute = SAMLAttribute.find_by_name(attr_data[:name])
    assoc = scope.find_or_initialize_by(saml_attribute_id: attribute.id)
    assoc.update!(extra_attrs)
    assoc
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

  def clean(touched_objs)
    grouped_objs = touched_objs.group_by(&:class)
    klasses = [IdentityProviderSAMLAttribute, ServiceProviderSAMLAttribute,
               IdentityProvider, ServiceProvider, SAMLAttribute, Organization]
    klasses.each do |klass|
      objs = grouped_objs.fetch(klass, [])
      klass.where.not(id: objs.map(&:id)).destroy_all
    end
  end
end
