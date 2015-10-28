require 'rails_helper'

RSpec.describe SubscriberRegistrationReport do
  let(:title) { Faker::Lorem.sentence }
  let(:header) { [['Name', 'Registration Date']] }
  let(:footer) { [['Name', 'Registration Date']] }
  let(:type) { 'subscriber-registrations' }

  let(:org_report) do
    SubscriberRegistrationReport.new(title, 'organizations')
  end

  let(:idp_report) do
    SubscriberRegistrationReport.new(title, 'identity_providers')
  end

  let(:sp_report) do
    SubscriberRegistrationReport.new(title, 'service_providers')
  end

  let(:rapid_c_report) do
    SubscriberRegistrationReport.new(title, 'rapid_connect_services')
  end
end
