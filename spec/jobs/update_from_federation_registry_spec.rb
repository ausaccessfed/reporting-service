# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UpdateFromFederationRegistry, type: :job do
  before(:all) { DatabaseCleaner.clean_with(:truncation) }

  around { |spec| Timecop.freeze { spec.run } }

  let(:default_org_data) do
    {
      id: org_fr_id,
      display_name: Faker::Company.name,
      functioning: true,
      created_at: 2.years.ago.utc.xmlschema,
      updated_at: 1.year.ago.utc.xmlschema
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
        entity: { entity_id: idp_entity_id },
        attributes: []
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
        entity: { entity_id: sp_entity_id },
        attribute_consuming_services: [
          { attributes: [] }
        ]
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
      name: Faker::Lorem.words.join('_').camelize(:lower),
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
    {
      organizations: organizations_response,
      attributes: attributes_response,
      identityproviders: identityproviders_response,
      serviceproviders: serviceproviders_response
    }.each do |endpoint, body|
      stub_request(:get, "#{base_url}/export/#{endpoint}")
        .with(headers: { 'Authorization' => /AAF-FR-EXPORT .+/ })
        .to_return(status: 200, body: body)
        .then.to_return { raise('endpoint should only be called once') }
    end
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

    shared_examples 'sync of an object with attributes' do
      context 'with a new attribute' do
        it 'adds the attribute' do
          expect { run }.to change(attribute_scope, :count).by(1)
          expect(attribute_scope.last.saml_attribute).to have_attributes(
            name: attr_data[:name], description: attr_data[:description]
          )
        end
      end

      context 'with an existing attribute' do
        let!(:attr) do
          create(:saml_attribute, name: attr_data[:name],
                                  core: false)
        end

        let!(:attr_assoc) do
          attribute_scope.create!(extra_assoc_attrs.merge(saml_attribute: attr))
        end

        it 'does not create a new object' do
          expect { run }.not_to change(attribute_scope, :count)
        end
      end

      context 'with a removed attribute' do
        let(:object_attribute_list) { [] }

        let!(:attr) do
          create(:saml_attribute, name: attr_data[:name],
                                  core: false)
        end

        let!(:attr_assoc) do
          attribute_scope.create!(extra_assoc_attrs.merge(saml_attribute: attr))
        end

        it 'removes the association object' do
          expect { run }.to change(attribute_scope, :count).by(-1)
        end
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

        context 'provided attributes' do
          let!(:object) do
            create(:identity_provider, entity_id: idp_entity_id,
                                       organization: organization)
          end

          let(:attribute_scope) { object.identity_provider_saml_attributes }
          let(:object_attribute_list) { [attr_data.slice(:id, :name)] }

          let(:expected_assoc_attrs) { {} }
          let(:extra_assoc_attrs) { {} }

          let(:idp_data) do
            default_idp_data.deep_merge(
              saml: {
                attributes: object_attribute_list
              }
            )
          end

          it_behaves_like 'sync of an object with attributes'
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

        context 'requested attributes' do
          let!(:object) do
            create(:service_provider, entity_id: sp_entity_id,
                                      organization: organization)
          end

          let(:attribute_scope) { object.service_provider_saml_attributes }
          let(:object_attribute_list) do
            [attr_data.slice(:id, :name).merge(is_required: true)]
          end

          let(:expected_assoc_attrs) { { optional: false } }
          let(:extra_assoc_attrs) { { optional: true } }

          let(:sp_data) do
            default_sp_data.deep_merge(
              saml: {
                attribute_consuming_services: [
                  { attributes: object_attribute_list }
                ]
              }
            )
          end

          it_behaves_like 'sync of an object with attributes'
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

    describe 'complete federation example' do
      let(:entity_ids) { Set.new }

      def unique_entity_id
        entity_id = Faker::Internet.url
        entity_id = Faker::Internet.url while entity_ids.include?(entity_id)

        entity_ids << entity_id
        entity_id
      end

      let(:organizations) do
        i = rand(9999)
        Array.new(10) do
          {
            id: (i += 1),
            display_name: Faker::Company.name,
            functioning: true,
            created_at: 2.years.ago.utc.xmlschema,
            updated_at: 1.year.ago.utc.xmlschema,
            identity_providers: [],
            service_providers: []
          }
        end
      end

      let(:attributes) do
        i = rand(9999)
        oid_tail_pattern = Array.new(rand(6)) { %w(# # # ## #####).sample }
                                .join('.')

        Array.new(20) do
          {
            id: (i += 1),
            name: Faker::Lorem.words.join('_').camelize(:lower),
            description: Faker::Lorem.sentence,
            oid: Faker::Base.numerify("#.#.#.#{oid_tail_pattern}"),
            category: {
              name: 'Core'
            }
          }
        end
      end

      let(:identity_providers) do
        i = rand(9999)
        Array.new(20) do
          attrs = attributes.sample(rand(10)).map do |a|
            a.slice(:name, :id)
          end

          {
            id: (i += 1),
            display_name: Faker::Company.name,
            organization: {
              id: organizations.sample[:id]
            },
            saml: {
              entity: { entity_id: unique_entity_id },
              attributes: attrs
            },
            functioning: true,
            created_at: 2.years.ago.utc.xmlschema,
            updated_at: 1.year.ago.utc.xmlschema
          }
        end
      end

      let(:service_providers) do
        i = rand(9999)
        Array.new(30) do
          attrs = attributes.sample(rand(10)).map do |a|
            a.slice(:name, :id).merge(is_required: [true, false].sample)
          end

          {
            id: (i += 1),
            display_name: Faker::Company.name,
            organization: {
              id: organizations.sample[:id]
            },
            saml: {
              entity: { entity_id: unique_entity_id },
              attribute_consuming_services: [
                { attributes: attrs }
              ]
            },
            functioning: true,
            created_at: 2.years.ago.utc.xmlschema,
            updated_at: 1.year.ago.utc.xmlschema
          }
        end
      end

      let(:organizations_response) do
        JSON.pretty_generate(organizations: organizations)
      end

      let(:identityproviders_response) do
        JSON.pretty_generate(identity_providers: identity_providers)
      end

      let(:serviceproviders_response) do
        JSON.pretty_generate(service_providers: service_providers)
      end

      let(:attributes_response) do
        JSON.pretty_generate(attributes: attributes)
      end

      it 'syncs the objects' do
        idp_attrs = identity_providers.flat_map { |o| o[:saml][:attributes] }
        sp_attrs = service_providers.flat_map do |o|
          o[:saml][:attribute_consuming_services]
            .flat_map { |s| s[:attributes] }
        end

        expect { run }.to change(Organization, :count).by(organizations.count)
          .and change(IdentityProvider, :count).by(identity_providers.count)
          .and change(ServiceProvider, :count).by(service_providers.count)
          .and change(SAMLAttribute, :count).by(attributes.count)
          .and change(IdentityProviderSAMLAttribute, :count).by(idp_attrs.count)
          .and change(ServiceProviderSAMLAttribute, :count).by(sp_attrs.count)

        expect(Organization.all.map(&:name))
          .to contain_exactly(*organizations.map { |o| o[:display_name] })

        expect(IdentityProvider.all.map(&:name))
          .to contain_exactly(*identity_providers.map { |o| o[:display_name] })

        expect(ServiceProvider.all.map(&:name))
          .to contain_exactly(*service_providers.map { |o| o[:display_name] })

        expect(SAMLAttribute.all.map(&:name))
          .to contain_exactly(*attributes.map { |o| o[:name] })

        expect { run }.to not_change(Organization, :count)
          .and not_change(IdentityProvider, :count)
          .and not_change(ServiceProvider, :count)
          .and not_change(SAMLAttribute, :count)
          .and not_change(IdentityProviderSAMLAttribute, :count)
          .and not_change(ServiceProviderSAMLAttribute, :count)
      end
    end
  end
end
