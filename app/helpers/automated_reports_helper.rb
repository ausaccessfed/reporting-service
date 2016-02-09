module AutomatedReportsHelper
  def target_name(type, target)
    return target.titleize if type.eql?('SubscriberRegistrationsReport')
    return 'Whole Federation' unless target_classes.include?(type)

    is_attribute = target_classes[type].to_s.eql?('SAMLAttribute')
    field = is_attribute ? :name : :entity_id
    target_classes[type].find_by(field => target).name
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
end
