# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Authentication::SubjectReceiver do
  let(:env) { {} }

  before { allow(subject).to receive(:update_roles) }

  context '#map_attributes' do
    let(:attrs) do
      keys = %w(edupersontargetedid auedupersonsharedtoken displayname mail)
      keys.reduce({}) { |a, e| a.merge(e => e) }
    end

    it 'maps the attributes' do
      expect(subject.map_attributes(env, attrs))
        .to eq(name: 'displayname',
               mail: 'mail',
               shared_token: 'auedupersonsharedtoken',
               targeted_id: 'edupersontargetedid')
    end
  end

  context '#subject' do
    let(:attrs) do
      attributes_for(:subject)
    end

    def run
      subject.subject(env, attrs)
    end

    context 'for an unknown subject' do
      it 'creates the subject' do
        expect { run }
          .to change(Subject, :count).by(1)
      end

      it 'returns the new subject' do
        obj = run
        expect(obj).to be_a(Subject)
        expect(obj).to have_attributes(attrs.except(:audit_comment))
      end

      it 'marks the new subject as complete' do
        expect(run).to be_complete
      end

      it 'updates roles for the subject' do
        expect(subject).to receive(:update_roles).with(an_instance_of(Subject))
        run
      end
    end

    context 'with an existing subject' do
      let!(:object) { create(:subject, attrs.merge(complete: false)) }

      it 'updates the attributes' do
        new = attributes_for(:subject).slice(:name, :mail)
        subject.subject(env, attrs.merge(new))
        expect(object.reload).to have_attributes(new)
      end

      it 'returns the existing subject' do
        expect(run).to eq(object)
      end

      it 'marks the subject as complete' do
        expect(run).to be_complete
      end

      it 'updates roles for the subject' do
        expect(subject).to receive(:update_roles).with(an_instance_of(Subject))
        run
      end

      context 'with a mismatched targeted id' do
        before { attrs[:targeted_id] = 'wrong' }

        it 'fails to provision the subject' do
          expect { run }.to raise_error(/targeted_id.*did not match/)
        end
      end

      context 'with a mismatched shared token' do
        before { attrs[:shared_token] = 'wrong' }

        it 'fails to provision the subject' do
          expect { run }.to raise_error(/shared_token.*did not match/)
        end
      end
    end

    context '#finish' do
      context 'when request url is available' do
        let(:session) { { 'return_url' => 'url' } }
        let(:env) { { 'rack.session' => session } }

        def run
          subject.finish(env)
        end

        it 'should redirect to request url' do
          expect(run).to eq([302, { 'Location' => 'url' }, []])
        end
      end

      context 'when request url is blank' do
        let(:session) { { 'return_url' => '' } }
        let(:env) { { 'rack.session' => session } }

        def run
          subject.finish(env)
        end

        it 'should redirect to request url' do
          expect(run).to eq([302, { 'Location' => '/' }, []])
        end
      end
    end
  end
end
