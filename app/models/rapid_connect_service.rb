class RapidConnectService < ActiveRecord::Base
  has_many :activations, as: :federation_object

  valhammer
end
