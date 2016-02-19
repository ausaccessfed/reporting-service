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
    target_must_be_valid_for_report_type
  end

  private

  TARGET_CLASSES = {
    'DailyDemandReport' => nil,
    'FederatedSessionsReport' => nil,
    'FederationGrowthReport' => nil,
    'IdentityProviderAttributesReport' => nil,
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

  def report_class_must_be_known
    return if TARGET_CLASSES.key?(report_class)
    errors.add(:report_class, 'must be of known type')
  end

  def target_must_be_valid_for_report_type
    return if report_class.nil?

    klass = TARGET_CLASSES[report_class]

    return target_must_be_nil if klass.nil?
    return target_must_be_object_type_identifier if klass == :object_type

    if klass.find_by_identifying_attribute(target)
      return klass.find_by_identifying_attribute(target).name
    end

    add_error 'must be appropriate for the report type'
  end

  def add_error(err)
    errors.add(:target, err)
  end

  def target_must_be_nil
    return 'Whole Federation' if target.nil?
    errors.add(:target, 'must be omitted for the report type')
  end

  OBJECT_TYPE_IDENTIFIERS =
    %w(identity_providers service_providers organizations
       rapid_connect_services services).freeze

  def target_must_be_object_type_identifier
    return report_class if OBJECT_TYPE_IDENTIFIERS.include?(target)

    add_error 'must be an object type identifier'
  end
end
