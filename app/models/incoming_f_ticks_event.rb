class IncomingFTicksEvent < ActiveRecord::Base
  valhammer

  # This model represents incoming data from rsyslog. The data is populated
  # outside of the app, so extra validations won't provide any value.
end
