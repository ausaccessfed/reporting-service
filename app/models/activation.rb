# frozen_string_literal: true

class Activation < ApplicationRecord
  belongs_to :federation_object, polymorphic: true

  valhammer
end
