class AutomatedReport < ActiveRecord::Base
  has_many :automated_report_instances
  has_many :automated_report_subscriptions

  valhammer

  validates :interval, inclusion: { in: %w(monthly quarterly yearly) }

  validate :target_must_be_valid_for_report_type,
           :report_class_must_be_known

  def interval
    value = super
    value && ActiveSupport::StringInquirer.new(value)
  end

  def target_name
    type = report_class

    return 'Identity Providers' if type == 'IdentityProviderUtilizationReport'
    return 'Service Providers' if type == 'ServiceProviderUtilizationReport'
    return 'Federation' if klass.nil?
    return target.titleize if klass.eql? :object_type

    target_object.name
  end

  def target_object
    klass.find_by_identifying_attribute(target)
  end

  private

  TARGET_CLASSES = {
    'DailyDemandReport' => nil,
    'FederatedSessionsReport' => nil,
    'FederationGrowthReport' => nil,
    'IdentityProviderAttributesReport' => nil,
    'IdentityProviderUtilizationReport' => nil,
    'ServiceProviderUtilizationReport' => nil,
    'SubscriberRegistrationsReport' => :object_type,
    'IdentityProviderDailyDemandReport' => IdentityProvider,
    'IdentityProviderDestinationServicesReport' => IdentityProvider,
    'IdentityProviderSessionsReport' => IdentityProvider,
    'ProvidedAttributeReport' => SAMLAttribute,
    'RequestedAttributeReport' => SAMLAttribute,
    'ServiceCompatibilityReport' => ServiceProvider,
    'ServiceProviderDailyDemandReport' => ServiceProvider,
    'ServiceProviderSessionsReport' => ServiceProvider,
    'ServiceProviderSourceIdentityProvidersReport' => ServiceProvider
  }.freeze

  private_constant :TARGET_CLASSES

  def klass
    TARGET_CLASSES[report_class]
  end

  def report_class_must_be_known
    return if TARGET_CLASSES.key?(report_class)
    errors.add(:report_class, 'must be of known type')
  end

  def target_must_be_valid_for_report_type
    return if report_class.nil?
    return target_must_be_nil if klass.nil?
    return target_must_be_object_type_identifier if klass == :object_type
    return if klass.find_by_identifying_attribute(target)

    errors.add(:target, 'must be appropriate for the report type')
  end

  def target_must_be_nil
    return if target.nil?
    errors.add(:target, 'must be omitted for the report type')
  end

  OBJECT_TYPE_IDENTIFIERS =
    %w(identity_providers service_providers organizations
       rapid_connect_services services).freeze

  def target_must_be_object_type_identifier
    return if OBJECT_TYPE_IDENTIFIERS.include?(target)
    errors.add(:target, 'must be an object type identifier')
  end
end
