class Activation < ActiveRecord::Base
  belongs_to :federation_object, polymorphic: true

  valhammer
end
