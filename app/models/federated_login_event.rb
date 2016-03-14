class FederatedLoginEvent < ActiveRecord::Base
  valhammer

  def generate_record(ticket_string)
    entries = fields(ticket_string)
    FederatedLoginEvent.create! attributes(entries)
  end

  private

  def fields(ticket_string)
    attributes = ticket_string.split('#').map do |s|
      k, v = s.split('=')
      { k => v }
    end

    attributes.reduce(&:merge)
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
