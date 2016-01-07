class RapidConnectService < ActiveRecord::Base
  include FederationObject

  belongs_to :organization

  has_many :activations, as: :federation_object

  valhammer
end
