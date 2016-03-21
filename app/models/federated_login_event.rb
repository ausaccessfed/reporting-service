class FederatedLoginEvent < ActiveRecord::Base
  valhammer

  def create_instance(ticket)
    entries = fields(ticket)
    update! login_event_hash(entries)
  end

  private

  def fields(str)
    str.split('#').each_with_object({}) do |s, hash|
      k, v = s.split('=')
      hash[k] = v
    end
  end

  def login_event_hash(entries)
    timestamp = nil
    timestamp = Time.zone.at(entries['TS'].to_i) if entries['TS'] =~ /^\d+$/

    { relying_party: entries['RP'],
      asserting_party: entries['AP'],
      result: entries['RESULT'],
      hashed_principal_name: entries['PN'],
      timestamp: timestamp }
  end
end
