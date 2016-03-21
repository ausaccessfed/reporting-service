class FederatedLoginEvent < ActiveRecord::Base
  valhammer

  def create_instance(data)
    data = fields(data)
    return unless login_event_hash(data)
    update! login_event_hash(data)
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

    attrs = { relying_party: data['RP'],
              asserting_party: data['AP'],
              result: data['RESULT'],
              hashed_principal_name: data['PN'],
              timestamp: timestamp }

    return attrs unless attrs.values.include? nil
  end
end
