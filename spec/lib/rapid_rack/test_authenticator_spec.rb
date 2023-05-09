require 'rack/lobster'

module RapidRack
  RSpec.describe TestAuthenticator, type: :feature do
    def build_app(prefix)
      opts = { receiver: receiver, secret: secret,
               issuer: issuer, audience: audience }
      Rack::Builder.new do
        use Rack::Lint
        map(prefix) { run TestAuthenticator.new(opts) }
        run Rack::Lobster.new
      end
    end

    let(:prefix) { '/auth' }
    let(:issuer) { 'https://rapid.example.com' }
    let(:audience) { 'https://service.example.com' }
    let(:secret) { '1234abcd' }
    let(:app) { build_app(prefix) }
    let(:receiver) do
      TemporaryTestClass.build_class {}
    end

    subject { response }

    context 'get /login' do
      def run
        get '/auth/login'
      end

      context 'with a JWT' do
        around do |example|
          TestAuthenticator.jwt = 'the jwt'
          example.run
        ensure
          TestAuthenticator.jwt = nil
        end

        before { run }
        it { is_expected.to be_successful }

        context 'login form' do
          subject { Capybara.string(response.body) }

          it { is_expected.to have_xpath("//form[@action='/auth/jwt']") }
          it { is_expected.to have_xpath("//form/input[@value='the jwt']") }
        end
      end

      context 'with no JWT' do
        before { TestAuthenticator.jwt = nil }

        it 'raises an error' do
          expect { run }.to raise_error('No login JWT was set')
        end
      end
    end

    context 'post /jwt' do
      it 'passes through to the parent' do
        post '/auth/jwt', params: { assertion: 'x.y.z' }
        expect(subject).to be_bad_request
      end
    end
  end
end
