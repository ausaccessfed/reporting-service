class Organization < ActiveRecord::Base
  include FederationObject

  has_many :activations, as: :federation_object

  valhammer

  validates :identifier, format: /\A[a-zA-Z0-9_-]+\z/
end
