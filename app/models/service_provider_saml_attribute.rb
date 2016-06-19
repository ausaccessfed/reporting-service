# frozen_string_literal: true
class ServiceProviderSAMLAttribute < ActiveRecord::Base
  belongs_to :service_provider
  belongs_to :saml_attribute

  valhammer
end
