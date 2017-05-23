# frozen_string_literal: true

class FederatedLoginEvent < ActiveRecord::Base
  valhammer

  def create_instance(event)
    data = fields(event.data)
    update login_event_hash(data)
  end

  private

  def fields(data)
    data.split('#').each_with_object({}) do |s, hash|
      k, v = s.split('=')
      hash[k] = v
    end
  end

  def login_event_hash(data)
    timestamp = nil
    timestamp = Time.zone.at(data['TS'].to_i) if data['TS'] =~ /^\d+$/

    { relying_party: data['RP'],
      asserting_party: data['AP'],
      result: data['RESULT'],
      hashed_principal_name: data['PN'],
      timestamp: timestamp }
  end
end
