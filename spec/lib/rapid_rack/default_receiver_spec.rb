module RapidRack
  RSpec.describe DefaultReceiver do
    let(:creator) { double }
    let(:overrides) { Module.new }

    subject do
      Class.new.tap do |klass|
        class <<klass
          attr_accessor :creator
          delegate :subject, to: :creator
        end
        klass.send(:extend, described_class)
        klass.send(:extend, overrides)
        klass.creator = creator
      end
    end

    let(:env) { { 'rack.session' => session } }
    let(:session) { {} }
    let(:claims) { { 'https://aaf.edu.au/attributes' => attrs } }
    let(:attrs) do
      {}
    end

    let(:authenticated_subject) { double(id: 1) }

    context '#receive' do
      before do
        allow(creator).to receive(:subject).with(anything, anything)
          .and_return(authenticated_subject)
      end

      def run
        subject.receive(env, claims)
      end

      it 'passes the attributes through to the subject method' do
        expect(creator).to receive(:subject).with(env, attrs)
          .and_return(authenticated_subject)

        run
      end

      it 'sets the session key' do
        expect { run }.to change { session['subject_id'] }.from(nil).to(1)
      end

      it 'redirects to a default location' do
        expect(run).to eq([302, { 'Location' => '/' }, []])
      end

      context 'with an overridden `map_attributes` method' do
        let(:overrides) do
          Module.new do
            def map_attributes(_, _)
              { 'remapped' => true }
            end
          end
        end

        it 'passes the mapped attributes through to the subject method' do
          expect(creator).to receive(:subject).with(env, 'remapped' => true)
            .and_return(authenticated_subject)

          run
        end
      end

      context 'with an overridden `store_id` method' do
        let(:overrides) do
          Module.new do
            def store_id(env, id)
              env['rack.session']['blarghn'] = id
            end
          end
        end

        it 'sets the configured session key' do
          expect { run }.to change { session['blarghn'] }.from(nil).to(1)
        end
      end

      context 'with an overridden `finish` method' do
        let(:overrides) do
          Module.new do
            def finish(env)
              header = { 'Location' => "/#{env['rack.session']['subject_id']}" }
              [204, header, []]
            end
          end
        end

        it 'responds using the overridden method' do
          expect(run).to eq([204, { 'Location' => '/1' }, []])
        end
      end
    end

    context '#logout' do
      let(:session) { { 'something' => 'x' } }

      def run
        subject.logout(env)
      end

      it 'clears the session' do
        expect { run }.to change { session }.to({})
      end

      it 'redirects to a default location' do
        expect(run).to eq([302, { 'Location' => '/' }, []])
      end
    end
  end
end
