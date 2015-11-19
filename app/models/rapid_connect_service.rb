class RapidConnectService < ActiveRecord::Base
  include FederationObject

  has_many :activations, as: :federation_object

  valhammer
end
