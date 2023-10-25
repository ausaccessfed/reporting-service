# frozen_string_literal: true

class FederatedLoginEvent < ApplicationRecord
  valhammer

  belongs_to :identity_provider, foreign_key: :asserting_party, primary_key: :entity_id

  belongs_to :service_provider, foreign_key: :relying_party, primary_key: :entity_id

  scope(
    :within_range,
    lambda { |start, finish| where(arel_table[:timestamp].gteq(start).and(arel_table[:timestamp].lteq(finish))) }
  )

  scope(:sessions, -> { where(result: 'OK') })

  def create_instance(event)
    data = fields(event.data)
    update login_event_hash(data)
  end

  private

  def fields(data)
    data
      .split('#')
      .each_with_object({}) do |s, hash|
        k, v = s.split('=')
        hash[k] = v
      end
  end

  def login_event_hash(data)
    timestamp = nil
    timestamp = Time.zone.at(data['TS'].to_i) if data['TS']&.match?(/^\d+$/)

    {
      relying_party: data['RP'],
      asserting_party: data['AP'],
      result: data['RESULT'],
      hashed_principal_name: data['PN'],
      timestamp:
    }
  end
end
