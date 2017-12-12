# frozen_string_literal: true

FactoryBot.define do
  factory :incoming_f_ticks_event do
    transient do
      sp_domain { Faker::Internet.domain_name }
      idp_domain { Faker::Internet.domain_name }

      relying_party { "https://sp.#{sp_domain}/shibboleth" }
      asserting_party { "https://idp.#{idp_domain}/idp/shibboleth" }

      event_timestamp { Faker::Time.backward }

      hashed_principal_name { SecureRandom.hex(32) }
    end

    ip { Faker::Internet.ip_v4_address }
    timestamp { Faker::Time.backward }

    data do
      fields = {
        'RP' => relying_party,
        'AP' => asserting_party,
        'TS' => event_timestamp.to_i,
        'PN' => hashed_principal_name,
        'RESULT' => 'OK'
      }

      fields.inject('F-TICKS/AAF/1.0#') { |str, (k, v)| "#{str}#{k}=#{v}#" }
    end
  end
end
