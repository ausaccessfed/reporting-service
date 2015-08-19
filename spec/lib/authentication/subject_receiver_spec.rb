require 'rails_helper'

RSpec.describe Authentication::SubjectReceiver do
  let(:env) { {} }

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

    context 'for an unknown subject' do
      it 'creates the subject' do
        expect { subject.subject(env, attrs) }
          .to change(Subject, :count).by(1)
      end

      it 'returns the new subject' do
        obj = subject.subject(env, attrs)
        expect(obj).to be_a(Subject)
        expect(obj).to have_attributes(attrs.except(:audit_comment))
      end

      it 'marks the new subject as complete' do
        expect(subject.subject(env, attrs)).to be_complete
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
        expect(subject.subject(env, attrs)).to eq(object)
      end

      it 'marks the subject as complete' do
        expect(subject.subject(env, attrs)).to be_complete
      end

      context 'with a mismatched targeted id' do
        def run
          subject.subject(env, attrs.merge(targeted_id: 'wrong'))
        end

        it 'fails to provision the subject' do
          expect { run }.to raise_error(/targeted_id.*did not match/)
        end
      end

      context 'with a mismatched shared token' do
        def run
          subject.subject(env, attrs.merge(shared_token: 'wrong'))
        end

        it 'fails to provision the subject' do
          expect { run }.to raise_error(/shared_token.*did not match/)
        end
      end
    end
  end
end
