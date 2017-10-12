# frozen_string_literal: true

class IncomingFTicksEvent < ApplicationRecord
  valhammer

  # This model represents incoming data from rsyslog. The data is populated
  # outside of the app, so extra validations won't provide any value.

  def discard!
    update!(discarded: true)
  end
end
