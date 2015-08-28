require 'rails_helper'

RSpec.describe Authentication::IdentityEnhancement do
  let(:klass) do
    Class.new do
      include Authentication::IdentityEnhancement
    end
  end

  subject { klass.new }

  let(:ide_entitlements) { [] }
  let(:ide_response_body) { { attributes: [] } }
  let(:ide_response) { { status: 200, body: JSON.generate(ide_response_body) } }

  before do
    shared_token = object.shared_token
    url = "https://ide.example.com/api/subjects/#{shared_token}/attributes"

    ide_config = {
      host: URI.parse(url).host,
      cert: 'spec/api.crt',
      key: 'spec/api.key'
    }

    allow(Rails.application)
      .to receive_message_chain(:config, :reporting_service, :ide)
      .and_return(ide_config)

    stub_request(:get, url).to_return(ide_response)
  end

  context '#update_roles' do
    let!(:object) { create(:subject) }

    def run
      subject.update_roles(object)
    end

    def roles
      object.subject_roles(true).map(&:role)
    end

    def subject_entitlements
      roles.map(&:entitlement)
    end

    context 'with a successful response from IdE' do
      let(:ide_attributes) do
        ide_entitlements.map do |v|
          { name: 'eduPersonEntitlement', value: v }
        end
      end

      let(:ide_response_body) { { attributes: ide_attributes } }
      let(:org_sha1) { SecureRandom.hex(20) }

      let(:ide_entitlements) do
        ["urn:mace:aaf.edu.au:ide:internal:organization:#{org_sha1}"]
      end

      context 'when the role does not exist' do
        it 'assigns a new role to the Subject' do
          expect { run }.to change(Role, :count).by(1)
          expect(subject_entitlements).to contain_exactly(*ide_entitlements)
        end
      end

      context 'when the role exists' do
        let!(:role) do
          create(:role, entitlement: ide_entitlements.first)
        end

        it 'assigns the existing role to the Subject' do
          expect { run }.not_to change(Role, :count)
          expect(subject_entitlements).to contain_exactly(*ide_entitlements)
        end
      end

      context 'with additional attributes' do
        let(:ide_attributes) do
          ide_entitlements.map do |v|
            { name: 'eduPersonAssurance', value: v }
          end
        end

        it 'ignores the extra attribute' do
          run
          expect(subject_entitlements).to be_empty
        end
      end
    end

    context 'with no attributes returned from IdE' do
      let!(:role) { create(:role) }
      before { object.roles << role }

      it 'removes the role from the subject' do
        expect { run }.to change { roles }.to be_empty
      end
    end

    context 'with a 404 response from IdE' do
      let!(:role) { create(:role) }
      before { object.roles << role }

      let(:ide_response) do
        { status: [404, 'Not Found'], body: '{"error":"no thing here"}' }
      end

      it 'removes entitlements from the subject' do
        expect { run }.to change { roles }.to be_empty
      end
    end

    context 'with an error response from IdE' do
      let(:ide_response) do
        { status: 500, body: '{"error":"something go wrong"}' }
      end

      it 'raises the error' do
        expect { run }.to raise_error(Net::HTTPFatalError)
      end
    end
  end
end
