# frozen_string_literal: true

unless ENV['AAF_DEV'].to_i == 1
  $stderr.puts <<-WARNING

  This is a destructive action, intended only for use in development
  environments where you wish to replace ALL data with generated sample data.

  If this is what you want, set the AAF_DEV environment variable to 1 before
  attempting to seed your database.

  WARNING
  raise('Not proceeding, missing AAF_DEV=1 environment variable')
end

include FactoryBot::Syntax::Methods

i = 0
time = nil

FactoryBot.define do
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

  orgs = create_list(:organization, 20)

  idps = (1..70).map do
    create(:identity_provider, organization: orgs.sample)
  end

  sps = (1..70).map do
    create(:service_provider, organization: orgs.sample)
  end

  rapid_services = (1..90).map do
    create(:rapid_connect_service, organization: orgs.sample)
  end

  [*idps, *sps, *rapid_services, *orgs].each do |object|
    next if rand > 0.9

    old_activation = create(:activation,
                            :deactivated,
                            federation_object: object)
    create(:activation,
           federation_object: object,
           activated_at: rand(old_activation.deactivated_at..Time.now.utc))
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

  puts

  start = 3.months.ago.utc.to_i
  finish = Time.now.utc.to_i

  events = Enumerator.new do |y|
    time = start

    while time < finish
      attrs = { user_agent: 'Mozilla/5.0', timestamp: Time.zone.at(time),
                ip: Faker::Internet.ip_v4_address, group: Faker::Lorem.word,
                unique_id: SecureRandom.urlsafe_base64, phase: 'request',
                initiating_sp: sps.sample.entity_id }

      y << attrs

      if rand < 0.95
        y << attrs.merge(
          phase: 'response',
          selection_method: %w[manual cookie].sample,
          selected_idp: idps.sample.entity_id,
          timestamp: Time.zone.at(time + rand(30))
        )
      end

      time += rand(60)
    end
  end

  def sql_quote(str)
    ActiveRecord::Base.connection.quote(str)
  end

  events.each_slice(1000) do |slice|
    sqlio = StringIO.new
    sqlio.puts(
      'INSERT INTO discovery_service_events ' \
      '(user_agent, ip, `group`, phase, unique_id, timestamp,' \
      ' selection_method, return_url, initiating_sp, selected_idp,' \
      ' created_at, updated_at) ' \
      'VALUES '
    )

    slice.each do |attrs|
      sqlio.puts(
        format(
          '(%<user_agent>s, %<ip>s, %<group>s, %<phase>s, %<unique_id>s,' \
          ' %<timestamp>s, %<selection_method>s, %<return_url>s,' \
          ' %<initiating_sp>s, %<selected_idp>s, now(), now()),',
          Hash.new('NULL').merge(attrs.transform_values { |v| sql_quote(v) })
        )
      )
    end

    sqlio.seek(-2, IO::SEEK_CUR)
    sqlio.puts(';')

    ActiveRecord::Base.connection.execute(sqlio.string)

    i += slice.length
    offset = (slice.last[:timestamp].to_i - start)
    pc = 100 * offset.to_f / (finish - start).to_f
    print("\rCreating Events: #{i} (#{pc.to_i}%)\e[0K")
  end
end

puts
