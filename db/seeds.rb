unless ENV['AAF_DEV'].to_i == 1
  $stderr.puts <<-EOF

  This is a destructive action, intended only for use in development
  environments where you wish to replace ALL data with generated sample data.

  If this is what you want, set the AAF_DEV environment variable to 1 before
  attempting to seed your database.

  EOF
  fail('Not proceeding, missing AAF_DEV=1 environment variable')
end

include FactoryGirl::Syntax::Methods

i = 0
time = nil

FactoryGirl.define do
  after(:create) do
    i += 1
    print("\rCreating Objects: #{i}\e[0K")
  end
end

ActiveRecord::Base.transaction do
  [
    Activation, IdentityProviderSAMLAttribute, ServiceProviderSAMLAttribute,
    DiscoveryServiceEvent,

    IdentityProvider, ServiceProvider, RapidConnectService, Organization,
    SAMLAttribute
  ].each(&:delete_all)

  idps = create_list(:identity_provider, 70)
  sps = create_list(:service_provider, 70)
  rapid_services = create_list(:rapid_connect_service, 90)
  orgs = create_list(:organization, 20)

  [*idps, *sps, *rapid_services, *orgs].each do |object|
    next if rand > 0.9

    create(:activation, :deactivated, :old, federation_object: object)
    next if rand > 0.7

    create(:activation, federation_object: object)
  end

  core_attributes = create_list(:saml_attribute, 20, :core_attribute)
  optional_attributes = create_list(:saml_attribute, 20)

  idps.each do |idp|
    [
      *core_attributes.reject { rand > 0.99 },
      *optional_attributes.reject { rand > 0.8 }
    ].each do |attr|
      create(:identity_provider_saml_attribute,
             identity_provider: idp, saml_attribute: attr)
    end
  end

  sps.each do |sp|
    [
      *core_attributes.reject { rand > 0.3 },
      *optional_attributes.reject { rand > 0.05 }
    ].each do |attr|
      optional = (rand > 0.7 && attr.core?) || (rand > 0.95)
      create(:service_provider_saml_attribute,
             service_provider: sp, saml_attribute: attr, optional: optional)
    end
  end

  start = 1.month.ago.utc.to_i
  finish = Time.now.utc.to_i
  time = start

  while time < finish
    attrs = { service_provider: sps.sample, timestamp: Time.zone.at(time) }

    create(:discovery_service_event, attrs.slice(:service_provider, :timestamp))

    if rand < 0.95
      attrs[:identity_provider] = idps.sample
      attrs[:timestamp] = Time.zone.at(time + rand(30))
      create(:discovery_service_event, :response, attrs)
    end

    time += rand(3600)
  end
end

puts
