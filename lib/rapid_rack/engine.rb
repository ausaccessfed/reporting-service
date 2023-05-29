# frozen_string_literal: true

module RapidRack
  class Engine < ::Rails::Engine
    isolate_namespace RapidRack
  end
end
