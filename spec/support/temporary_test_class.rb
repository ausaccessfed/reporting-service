# frozen_string_literal: true

module TemporaryTestClass
  def self.build_class(&)
    klass = Class.new(&)
    name = "TestClass#{SecureRandom.hex}"
    RapidRack.const_set(name, klass)
    "RapidRack::#{name}"
  end
end
