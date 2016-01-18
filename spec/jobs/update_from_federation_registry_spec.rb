require 'rails_helper'

RSpec.describe UpdateFromFederationRegistry, type: :job do
  before(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:default_org_data) do
    {
      id: org_fr_id,
      display_name: Faker::Company.name,
      functioning: true,
      created_at: 2.years.ago.utc.xmlschema,
      updated_at: 1.year.ago.utc.xmlschema,
      identity_providers: [],
      service_providers: []
    }
  end

  let(:default_idp_data) do
    {
      id: 1,
      display_name: Faker::Company.name,
      organization: {
        id: default_org_data[:id]
      },
      saml: {
        entity: { entity_id: idp_entity_id }
      },
      functioning: true,
      created_at: 2.years.ago.utc.xmlschema,
      updated_at: 1.year.ago.utc.xmlschema
    }
  end

  let(:default_sp_data) do
    {
      id: 1,
      display_name: Faker::Company.name,
      organization: {
        id: default_org_data[:id]
      },
      saml: {
        entity: { entity_id: sp_entity_id }
      },
      functioning: true,
      created_at: 2.years.ago.utc.xmlschema,
      updated_at: 1.year.ago.utc.xmlschema
    }
  end

  let(:default_attr_data) do
    oid_tail_pattern = Array.new(rand(6)) { %w(# # # ## #####).sample }
                            .join('.')
    {
      id: 1,
      name: Faker::Lorem.words.map(&:titleize).join.camelize,
      description: Faker::Lorem.sentence,
      oid: Faker::Base.numerify("#.#.#.#{oid_tail_pattern}"),
      category: {
        name: 'Core'
      }
    }
  end

  let(:org_fr_id) { rand(10_000) }
  let(:sp_entity_id) { Faker::Internet.url }
  let(:idp_entity_id) { Faker::Internet.url }
  let(:org_data) { default_org_data }
  let(:idp_data) { nil }
  let(:sp_data) { nil }
  let(:attr_data) { default_attr_data }
  let(:extra_obj_attrs) { {} }
  let(:base_url) { 'https://manager.example.edu/federationregistry' }

  let(:organizations_response) do
    JSON.pretty_generate(organizations: [org_data].compact)
  end

  let(:identityproviders_response) do
    JSON.pretty_generate(identity_providers: [idp_data].compact)
  end

  let(:serviceproviders_response) do
    JSON.pretty_generate(service_providers: [sp_data].compact)
  end

  let(:attributes_response) do
    JSON.pretty_generate(attributes: [attr_data].compact)
  end

  let(:org_identifier) do
    hash = OpenSSL::Digest::SHA256.new.digest("aaf:subscriber:#{org_fr_id}")
    Base64.urlsafe_encode64(hash, padding: false)
  end

  before do
    export_api_opts = { headers: { 'Authorization' => /AAF-FR-EXPORT .+/ } }

    stub_request(:get, "#{base_url}/export/organizations")
      .with(export_api_opts)
      .to_return(status: 200, body: organizations_response)

    stub_request(:get, "#{base_url}/export/attributes")
      .with(export_api_opts)
      .to_return(status: 200, body: attributes_response)

    stub_request(:get, "#{base_url}/export/identityproviders")
      .with(export_api_opts)
      .to_return(status: 200, body: identityproviders_response)

    stub_request(:get, "#{base_url}/export/serviceproviders")
      .with(export_api_opts)
      .to_return(status: 200, body: serviceproviders_response)
  end

  describe '#perform' do
    def run
      subject.perform
    end

    shared_examples 'sync of a new object' do
      it 'creates the object' do
        expect { run }.to change(scope, :count).by(1)
        expect(scope.last).to have_attributes(expected_attrs)
      end

      it 'activates the object' do
        run
        expect(scope.last.activations).not_to be_empty
        expect(scope.last.activations.first).to have_attributes(
          activated_at: Time.parse(org_data[:created_at]).utc,
          deactivated_at: nil
        )
      end

      context 'when the object is not functioning' do
        let(:extra_obj_attrs) { { functioning: false } }

        it 'marks the object as deactivated' do
          run
          expect(scope.last.activations).not_to be_empty
          expect(scope.last.activations.first).to have_attributes(
            activated_at: Time.parse(obj_data[:created_at]).utc,
            deactivated_at: Time.parse(obj_data[:updated_at]).utc
          )
        end
      end
    end

    shared_examples 'sync of an existing object' do
      let!(:activation) { create(:activation, federation_object: object) }

      it 'updates the object' do
        expect { run }.not_to change(scope, :count)
        expect { object.reload }.to change { object.attributes.symbolize_keys }
          .to include(expected_attrs)
      end

      it 'activates the object' do
        expect { run }.not_to change(object.activations, :count)
        expect(object.activations.first).to have_attributes(
          activated_at: Time.parse(obj_data[:created_at]).utc,
          deactivated_at: nil
        )
      end

      context 'when the object is not functioning' do
        let(:extra_obj_attrs) { { functioning: false } }

        it 'marks the object as deactivated' do
          expect { run }.not_to change(object.activations, :count)
          expect(object.activations.first).to have_attributes(
            activated_at: Time.parse(obj_data[:created_at]).utc,
            deactivated_at: Time.parse(obj_data[:updated_at]).utc
          )
        end
      end
    end

    shared_examples 'sync of a removed object' do
      it 'removes the object' do
        expect { run }.to change(scope, :count).by(-1)
        expect { object.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'Organization sync' do
      let(:scope) { Organization }
      let(:expected_attrs) do
        identifier = org_identifier
        { identifier: identifier, name: org_data[:display_name] }
      end

      let(:org_data) { default_org_data.merge(extra_obj_attrs) }
      let(:obj_data) { org_data }

      context 'for a new organization' do
        it_behaves_like 'sync of a new object'
      end

      context 'for an exising organization' do
        let!(:object) { create(:organization, identifier: org_identifier) }

        it_behaves_like 'sync of an existing object'
      end

      context 'for a removed organiation' do
        let!(:object) { create(:organization, identifier: org_identifier) }
        let(:org_data) { nil }

        it_behaves_like 'sync of a removed object'
      end
    end

    describe 'SAML entities' do
      let!(:organization) do
        create(:organization, identifier: org_identifier)
      end

      let!(:org_activation) do
        create(:activation, federation_object: organization)
      end

      let(:expected_attrs) do
        {
          name: obj_data[:display_name],
          entity_id: obj_data[:saml][:entity][:entity_id]
        }
      end

      describe 'IdentityProvider sync' do
        let(:idp_data) { default_idp_data.merge(extra_obj_attrs) }
        let(:obj_data) { idp_data }
        let(:scope) { organization.identity_providers }

        context 'for a new identity provider' do
          it_behaves_like 'sync of a new object'

          context 'with the wrong organization' do
            let(:idp_data) do
              default_idp_data.merge(
                organization: { id: (default_org_data[:id] + 1) }
              )
            end

            it 'ignores the identity provider' do
              expect { run }.not_to change(scope, :count)
            end
          end
        end

        context 'for an existing identity provider' do
          let!(:object) do
            create(:identity_provider, entity_id: idp_entity_id,
                                       organization: organization)
          end

          it_behaves_like 'sync of an existing object'
        end

        context 'for a removed identity provider' do
          let(:idp_data) { nil }

          let!(:object) do
            create(:identity_provider, entity_id: idp_entity_id,
                                       organization: organization)
          end

          it_behaves_like 'sync of a removed object'
        end
      end

      describe 'ServiceProvider sync' do
        let(:sp_data) { default_sp_data.merge(extra_obj_attrs) }
        let(:obj_data) { sp_data }
        let(:scope) { organization.service_providers }

        context 'for a new service provider' do
          it_behaves_like 'sync of a new object'

          context 'with the wrong organization' do
            let(:sp_data) do
              default_sp_data.merge(
                organization: { id: (default_org_data[:id] + 1) }
              )
            end

            it 'ignores the service provider' do
              expect { run }.not_to change(scope, :count)
            end
          end
        end

        context 'for an existing service provider' do
          let!(:object) do
            create(:service_provider, entity_id: sp_entity_id,
                                      organization: organization)
          end

          it_behaves_like 'sync of an existing object'
        end

        context 'for a removed service provider' do
          let(:sp_data) { nil }

          let!(:object) do
            create(:service_provider, entity_id: sp_entity_id,
                                      organization: organization)
          end

          it_behaves_like 'sync of a removed object'
        end
      end
    end

    describe 'SAMLAttribute sync' do
      let(:attr_data) { default_attr_data }

      context 'for a new attribute' do
        it 'creates the object' do
          expect { run }.to change(SAMLAttribute, :count).by(1)
          expect(SAMLAttribute.last).to have_attributes(name: attr_data[:name])
        end
      end

      context 'for an existing attribute' do
        let!(:attr) do
          create(:saml_attribute, name: attr_data[:name],
                                  core: false)
        end

        it 'updates the object' do
          expect { run }.not_to change(SAMLAttribute, :count)
          expected_attrs = {
            core: true,
            description: attr_data[:description]
          }
          expect { attr.reload }.to change { attr.attributes.symbolize_keys }
            .to include(expected_attrs)
        end
      end

      context 'for a removed attribute' do
        let(:attr_data) { nil }
        let!(:attr) { create(:saml_attribute) }

        it 'removes the object' do
          expect { run }.to change(SAMLAttribute, :count).by(-1)
          expect { attr.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
