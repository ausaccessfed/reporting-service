class FederatedLoginEvent < ActiveRecord::Base
  valhammer

  def generate_record(ticket_string)
    entries = fields(ticket_string)
    update! attributes(entries)
  end

  private

  def fields(ticket_string)
    ticket_string.split('#').each_with_object({}) do |s, hash|
      k, v = s.split('=')
      hash[k] = v
    end
  end

  def attributes(entries)
    {
      relying_party: entries['RP'],
      asserting_party: entries['AP'],
      result: entries['RESULT'],
      hashed_principal_name: entries['PN'],
      timestamp: Time.current
    }
  end
end
