# frozen_string_literal: true

require 'rack/lobster'

RSpec.describe RapidRack::Authenticator, type: :feature do
  def build_app(prefix)
    opts = { url: url, receiver: receiver, secret: secret,
             issuer: issuer, audience: audience, error_handler: handler }
    Rack::Builder.new do
      map(prefix) { run described_class.new(opts) }
      run Rack::Lobster.new
    end
  end

  before do
    config = Rails.application.config.reporting_service.rapid_connect
    config[:rack][:receiver] = receiver
    config[:rack][:error_handler] = handler

    allow(Rails.application.config.reporting_service).to receive(:rapid_connect)
      .and_return(config)
  end

  let(:prefix) { '/auth' }
  let(:issuer) { 'https://rapid.example.com' }
  let(:audience) { 'https://service.example.com' }
  let(:url) { 'https://rapid.example.com/jwt/authnrequest/research/abcd1234' }
  let(:secret) { '1234abcd' }
  let(:app) { build_app(prefix) }

  subject { response }

  let(:handler) { nil }
  let(:receiver) do
    TemporaryTestClass.build_class do
      def receive(_, _)
        [200, {}, ['Permitted']]
      end

      def logout(_)
        [200, {}, ['Logged Out!']]
      end

      def register_jti(*)
        true
      end
    end
  end

  context 'get /nonexistent' do
    before { get '/auth/nonexistent' }
    it { is_expected.to be_not_found }
  end

  context 'get /login' do
    before { get '/auth/login' }

    it 'redirects to the url' do
      expect(response).to be_redirect
      expect(response['Location']).to eq(url)
    end
  end

  context 'post /login' do
    before { post '/auth/login' }
    it { is_expected.to be_method_not_allowed }
  end

  context 'get /logout' do
    before { get '/auth/logout' }
    it 'responds using the receiver' do
      expect(response).to be_successful
      expect(response.body).to have_content('Logged Out!')
    end
  end

  context 'post /logout' do
    before { post '/auth/logout' }
    it { is_expected.to be_method_not_allowed }
  end

  context 'get /jwt' do
    before { get '/auth/jwt' }
    it { is_expected.to be_method_not_allowed }
  end

  context 'post /jwt' do
    before { post '/auth/jwt', params: { assertion: assertion } }

    let(:attrs) do
      {
        cn: 'Test User', displayname: 'Test User X', surname: 'User',
        givenname: 'Test', mail: 'testuser@example.com', o: 'Test Org',
        edupersonscopedaffiliation: 'member@example.com',
        edupersonprincipalname: 'testuser@example.com',
        auedupersonsharedtoken: 'secret',
        edupersontargetedid: "#{issuer}!#{audience}!abcd"
      }
    end

    let(:valid_claims) do
      {
        aud: audience, iss: issuer, iat: Time.zone.now, typ: 'authnresponse',
        nbf: 1.minute.ago, exp: 2.minutes.from_now,
        jti: 'accept', 'https://aaf.edu.au/attributes' => attrs
      }
    end

    let(:assertion) { JSON::JWT.new(claims).sign(secret).to_s }

    context 'with an invalid assertion' do
      let(:assertion) { 'x.y.z' }
      it { is_expected.to be_bad_request }
    end

    context 'with a valid assertion' do
      let(:claims) { valid_claims }

      it 'responds using the receiver' do
        expect(response).to be_successful
        expect(response.body).to have_content('Permitted')
      end
    end

    shared_examples 'an invalid claims set' do |field|
      it { is_expected.to be_bad_request }

      context 'with an error handler' do
        let(:handler) do
          TemporaryTestClass.build_class do
            def handle(_env, exception)
              [403, {}, ["Surprise!\n", exception.message]]
            end
          end
        end

        it 'uses the error handler to respond' do
          expect(subject).to be_forbidden
          expect(subject.body).to have_content('Surprise!')
        end

        it 'complains about the invalid field' do
          val = claims[field]
          expected = if val.nil?
                       "nil #{field}"
                     else
                       "bad #{field}: #{val}"
                     end

          expect(subject.body).to have_content(expected)
        end
      end
    end

    context 'with a nil audience' do
      let(:claims) { valid_claims.merge(aud: nil) }
      it_behaves_like 'an invalid claims set', :aud
    end

    context 'with an invalid audience' do
      let(:claims) { valid_claims.merge(aud: 'invalid') }
      it_behaves_like 'an invalid claims set', :aud
    end

    context 'with a nil issuer' do
      let(:claims) { valid_claims.merge(iss: nil) }
      it_behaves_like 'an invalid claims set', :iss
    end

    context 'with an invalid issuer' do
      let(:claims) { valid_claims.merge(iss: 'invalid') }
      it_behaves_like 'an invalid claims set', :iss
    end

    context 'with a nil type' do
      let(:claims) { valid_claims.merge(typ: nil) }
      it_behaves_like 'an invalid claims set', :typ
    end

    context 'with an invalid type' do
      let(:claims) { valid_claims.merge(typ: 'blarghn') }
      it_behaves_like 'an invalid claims set', :typ
    end

    context 'with a nil jti' do
      let(:claims) { valid_claims.merge(jti: nil) }
      it_behaves_like 'an invalid claims set', :jti
    end

    context 'with a replayed jti' do
      let(:receiver) do
        TemporaryTestClass.build_class do
          def register_jti(*)
            false
          end
        end
      end

      let(:claims) { valid_claims.merge(jti: 'blarghn') }
      it_behaves_like 'an invalid claims set', :jti
    end

    context 'with a nil nbf' do
      let(:claims) { valid_claims.merge(nbf: nil) }
      it_behaves_like 'an invalid claims set', :nbf
    end

    context 'with an invalid nbf' do
      let(:claims) { valid_claims.merge(nbf: 2.minutes.from_now) }
      it_behaves_like 'an invalid claims set', :nbf
    end

    context 'with a non-numeric nbf' do
      let(:claims) { valid_claims.merge(nbf: 'a') }
      it_behaves_like 'an invalid claims set', :nbf
    end

    context 'with a nil exp' do
      let(:claims) { valid_claims.merge(exp: nil) }
      it_behaves_like 'an invalid claims set', :exp
    end

    context 'with an invalid exp' do
      let(:claims) { valid_claims.merge(exp: 1.minute.ago) }
      it_behaves_like 'an invalid claims set', :exp
    end

    context 'with a non-numeric exp' do
      let(:claims) { valid_claims.merge(exp: 'a') }
      it_behaves_like 'an invalid claims set', :exp
    end

    context 'with a nil iat' do
      let(:claims) { valid_claims.merge(iat: nil) }
      it_behaves_like 'an invalid claims set', :iat
    end

    context 'with an invalid iat' do
      let(:claims) { valid_claims.merge(iat: 10.minutes.ago) }
      it_behaves_like 'an invalid claims set', :iat
    end

    context 'with a non-numeric iat' do
      let(:claims) { valid_claims.merge(iat: 'a') }
      it_behaves_like 'an invalid claims set', :iat
    end
  end
end
