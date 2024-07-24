# frozen_string_literal: true

RSpec.describe RapidRack::Engine, type: :feature do
  let(:opts) { Rails.application.config.reporting_service.rapid_connect[:rack] }

  let(:issuer) { opts[:issuer] }
  let(:audience) { opts[:audience] }
  let(:url) { opts[:url] }
  let(:secret) { opts[:secret] }
  let(:handler) { nil }
  let(:app) { Rails.application }

  # Unfortunately the neatest way to get access to a routed application in
  # the engine.
  let(:engine_app) { RapidRack::Engine.routes.routes.routes[0].app }

  subject { response }

  before do
    error_handler = handler.try(:constantize).try(:new) || engine_app

    config = Rails.application.config.reporting_service.rapid_connect
    config[:rack][:error_handler] = error_handler

    allow(Rails.application.config.reporting_service).to receive(:rapid_connect).and_return(config)
  end

  context 'full integration' do
    let(:attrs) do
      {
        cn: 'Test User',
        displayname: 'Test User X',
        surname: 'User',
        givenname: 'Test',
        mail: 'testuser@example.com',
        o: 'Test Org',
        edupersonscopedaffiliation: 'member@example.com',
        edupersonprincipalname: 'testuser@example.com',
        auedupersonsharedtoken: 'somesecret',
        edupersontargetedid: "#{issuer}!#{audience}!abcd"
      }
    end

    let(:valid_claims) do
      {
        :aud => audience,
        :iss => issuer,
        :iat => Time.zone.now,
        :typ => 'authnresponse',
        :nbf => 1.minute.ago,
        :exp => 2.minutes.from_now,
        :jti => 'accept',
        'https://aaf.edu.au/attributes' => attrs
      }
    end

    let(:assertion) { JSON::JWT.new(claims).sign(secret).to_s }
    let(:claims) { valid_claims }
    let(:session) { {} }

    def run
      post '/auth/jwt', params: { assertion: }
    end

    it 'creates the subject' do
      expect { run }.to change(Subject, :count).by(1)
      expect(response).to be_redirect
      expect(response['Location']).to eq('/')
      expect(request.session[:subject_id]).to eq(Subject.last.id)
    end

    context '#logout' do
      def run
        get '/auth/logout'
      end

      context 'when sesssion' do
        def run
          post '/auth/jwt', params: { assertion: }
          get '/auth/logout'
        end
        it 'should redirect to / and reset session' do
          expect(run).to eq(302)
          expect(response['Location']).to eq('/')
          expect(request.session[:subject_id]).to eq(nil)
        end
      end

      context 'when no sesssion' do
        it 'should redirect to / and reset session' do
          expect(run).to eq(302)
          expect(response['Location']).to eq('/')
          expect(request.session[:subject_id]).to eq(nil)
        end
      end
    end
  end
end
