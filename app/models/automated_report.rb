class AutomatedReport < ActiveRecord::Base
  valhammer

  validates :interval, inclusion: { in: %w(monthly quarterly yearly) }

  validate :target_must_be_valid_for_report_type,
           :report_class_must_be_known

  def interval
    value = super
    value && ActiveSupport::StringInquirer.new(value)
  end

  private

  TARGET_CLASSES = {
    'DailyDemandReport' => nil,
    'FederatedSessionsReport' => nil,
    'FederationGrowthReport' => nil,
    'SubscriberRegistrationReport' => nil,
    'IdentityProviderAttributesReport' => nil,
    'IdentityProviderDailyDemandReport' => IdentityProvider,
    'IdentityProviderDestinationServicesReport' => IdentityProvider,
    'IdentityProviderSessionsReport' => IdentityProvider,
    'ProvidedAttributeReport' => SAMLAttribute,
    'RequestedAttributeReport' => SAMLAttribute,
    'ServiceCompatibilityReport' => ServiceProvider,
    'ServiceProviderDailyDemandReport' => ServiceProvider,
    'ServiceProviderSessionsReport' => ServiceProvider,
    'ServiceProviderSourceIdentityProvidersReport' => ServiceProvider
  }

  private_constant :TARGET_CLASSES

  def report_class_must_be_known
    return if TARGET_CLASSES.key?(report_class)
    errors.add(:report_class, 'must be of known type')
  end

  def target_must_be_valid_for_report_type
    return if report_class.nil?

    klass = TARGET_CLASSES[report_class]
    return target_must_be_nil if klass.nil?

    return if klass.find_by_identifying_attribute(target)
    errors.add(:target, 'must be appropriate for the report type')
  end

  def target_must_be_nil
    return if target.nil?
    errors.add(:target, 'must be omitted for the report type')
  end
end
