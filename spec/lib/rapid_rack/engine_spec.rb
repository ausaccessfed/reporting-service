module RapidRack
  RSpec.describe Engine, type: :feature do
    let(:opts) { YAML.load_file('spec/dummy/config/rapidconnect.yml') }
    let(:issuer) { opts['issuer'] }
    let(:audience) { opts['audience'] }
    let(:url) { opts['url'] }
    let(:secret) { opts['secret'] }
    let(:receiver_class) { 'TestReceiver' }
    let(:handler) { nil }
    let(:app) { Rails.application }

    # Unfortunately the neatest way to get access to a routed application in
    # the engine.
    let(:engine_app) { RapidRack::Engine.routes.routes.routes[0].app }

    subject { last_response }

    before do
      error_handler = handler.try(:constantize).try(:new) || engine_app
      engine_app.instance_variable_set(:@error_handler, error_handler)
      engine_app.instance_variable_set(:@receiver, receiver_class.constantize)
    end

    it_behaves_like 'an authenticator'

    context 'full integration' do
      let(:receiver_class) do
        build_class do
          include DefaultReceiver
          include RedisRegistry

          def map_attributes(_env, attrs)
            {
              targeted_id: attrs['edupersontargetedid'],
              email: attrs['mail'],
              name: attrs['displayname']
            }
          end

          def subject(_env, attrs)
            identifier = attrs.slice(:targeted_id)
            TestSubject.find_or_initialize_by(identifier).tap do |subject|
              subject.update_attributes!(attrs)
            end
          end
        end
      end

      let(:attrs) do
        {
          cn: 'Test User', displayname: 'Test User X', surname: 'User',
          givenname: 'Test', mail: 'testuser@example.com', o: 'Test Org',
          edupersonscopedaffiliation: 'member@example.com',
          edupersonprincipalname: 'testuser@example.com',
          edupersontargetedid: "#{issuer}!#{audience}!abcd"
        }
      end

      let(:valid_claims) do
        {
          aud: audience, iss: issuer, iat: Time.now, typ: 'authnresponse',
          nbf: 1.minute.ago, exp: 2.minutes.from_now,
          jti: 'accept', 'https://aaf.edu.au/attributes' => attrs
        }
      end

      let(:receiver) { receiver_class.constantize.new }
      let(:assertion) { JSON::JWT.new(claims).sign(secret).to_s }
      let(:claims) { valid_claims }
      let(:session) { {} }

      def run
        post '/auth/jwt', assertion: assertion
      end

      it 'creates the subject' do
        expect { run }.to change(TestSubject, :count).by(1)
      end

      it 'redirects to /' do
        run
        expect(last_response).to be_redirect
        expect(last_response['Location']).to eq('/')
      end

      it 'sets the session' do
        run
        expect(last_request.session[:subject_id]).to eq(TestSubject.last.id)
      end
    end

    context '#authenticator' do
      before do
        expect_any_instance_of(RapidRack::Engine)
          .to receive(:configuration).at_least(:once).and_return(configuration)
      end

      subject { RapidRack::Engine.authenticator }

      context 'in development mode' do
        let(:configuration) { { development_mode: true } }
        it { is_expected.to eq('RapidRack::MockAuthenticator') }
      end

      context 'in test mode' do
        let(:configuration) { { test_mode: true } }
        it { is_expected.to eq('RapidRack::TestAuthenticator') }
      end

      context 'with no mode' do
        let(:configuration) { {} }
        it { is_expected.to eq('RapidRack::Authenticator') }
      end
    end
  end
end
