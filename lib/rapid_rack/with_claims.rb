module RapidRack
  module WithClaims
    def with_claims(env, assertion)
      claims = JSON::JWT.decode(assertion, secret)
      validate_claims(claims)
      yield claims
    rescue JSON::JWT::Exception => e
      error_handler.handle(env, e)
    rescue InvalidClaim => e
      error_handler.handle(env, e)
    end

    private

    InvalidClaim = Class.new(StandardError)
    private_constant :InvalidClaim

    def validate_claims(claims)
      validate_aud(claims)
      validate_iss(claims)
      validate_typ(claims)
      validate_jti(claims)
      validate_nbf(claims)
      validate_exp(claims)
      validate_iat(claims)
    end

    def validate_jti(claims)
      reject_claim_if(claims, 'jti') { |jti| !receiver.register_jti(jti) }
    end

    def validate_iat(claims)
      reject_claim_if(claims, 'iat') { |iat| (iat - Time.now.to_i).abs > 60 }
    end

    def validate_exp(claims)
      reject_claim_if(claims, 'exp') { |exp| Time.at(exp) < Time.now }
    end

    def validate_nbf(claims)
      reject_claim_if(claims, 'nbf', &:zero?)
      reject_claim_if(claims, 'nbf') { |nbf| Time.at(nbf) > Time.now }
    end

    def validate_typ(claims)
      reject_claim_if(claims, 'typ') { |v| v != 'authnresponse' }
    end

    def validate_iss(claims)
      reject_claim_if(claims, 'iss') { |v| v != issuer }
    end

    def validate_aud(claims)
      reject_claim_if(claims, 'aud') { |v| v != audience }
    end

    def reject_claim_if(claims, key)
      val = claims[key]
      raise(InvalidClaim, "nil #{key}") unless val
      raise(InvalidClaim, "bad #{key}: #{val}") if yield(val)
    end
  end
end
