# frozen_string_literal: true

class ServiceProviderSAMLAttribute < ApplicationRecord
  belongs_to :service_provider
  belongs_to :saml_attribute

  valhammer
end
