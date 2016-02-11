module AutomatedReportsHelper
  def target_name(type, target)
    return target.titleize if type.eql?('SubscriberRegistrationsReport')
    return 'Whole Federation' unless target_classes.include?(type)

    objects = target_classes[type]
    is_attribute = target_classes[type].to_s.eql?('SAMLAttribute')

    return fin_by_name(objects, target) if is_attribute
    find_by_entity_id(objects, target)
  end

  def target_classes
    {
      'IdentityProviderDailyDemandReport' => IdentityProvider,
      'IdentityProviderDestinationServicesReport' => IdentityProvider,
      'IdentityProviderSessionsReport' => IdentityProvider,
      'ProvidedAttributeReport' => SAMLAttribute,
      'RequestedAttributeReport' => SAMLAttribute,
      'ServiceCompatibilityReport' => ServiceProvider,
      'ServiceProviderDailyDemandReport' => ServiceProvider,
      'ServiceProviderSessionsReport' => ServiceProvider,
      'ServiceProviderSourceIdentityProvidersReport' => ServiceProvider }
  end

  def find_by_entity_id(objects, target)
    objects.all.detect { |s| s.entity_id.eql? target }.name
  end

  def fin_by_name(objects, target)
    objects.all.detect { |s| s.name.eql? target }.name
  end
end
