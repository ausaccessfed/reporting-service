# frozen_string_literal: true

require 'active_support/concern'

module FederationObject
  extend ActiveSupport::Concern

  included do
    scope(:active, lambda {
      joins(:activations).where(activations: { deactivated_at: nil }).uniq
    })
  end
end
