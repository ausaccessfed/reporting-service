require 'rack/lobster'

module RapidRack
  RSpec.describe Authenticator, type: :feature do
    def build_app(prefix)
      opts = { url: url, receiver: receiver, secret: secret,
               issuer: issuer, audience: audience, error_handler: handler }
      Rack::Builder.new do
        use Rack::Lint
        map(prefix) { run Authenticator.new(opts) }
        run Rack::Lobster.new
      end
    end

    let(:prefix) { '/auth' }
    let(:issuer) { 'https://rapid.example.com' }
    let(:audience) { 'https://service.example.com' }
    let(:url) { 'https://rapid.example.com/jwt/authnrequest/research/abcd1234' }
    let(:secret) { '1234abcd' }
    let(:app) { build_app(prefix) }

    subject { last_response }

    it_behaves_like 'an authenticator'
  end
end
