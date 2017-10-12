# frozen_string_literal: true

class Organization < ApplicationRecord
  include FederationObject

  has_many :activations, as: :federation_object, dependent: :destroy
  has_many :identity_providers, dependent: :destroy
  has_many :service_providers, dependent: :destroy
  has_many :rapid_connect_services, dependent: :destroy

  valhammer

  validates :identifier, format: /\A[a-zA-Z0-9_-]+\z/

  def self.find_by_identifying_attribute(value)
    find_by(identifier: value)
  end
end
