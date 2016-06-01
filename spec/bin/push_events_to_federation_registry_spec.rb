# frozen_string_literal: true
require 'rails_helper'

load Rails.root.join('bin/push_events_to_federation_registry.rb').to_s

RSpec.describe PushEventsToFederationRegistry do
  let(:config) { Rails.application.config.database_configuration[Rails.env] }
  let(:client) { subject.mysql_client }
  let(:redis) { Redis.new }
  let(:ds_host) { "ds.#{Faker::Internet.domain_name}" }

  let(:selected_idp) do
    "https://idp.#{Faker::Internet.domain_name}/idp/shibboleth"
  end

  let(:initiating_sp) do
    "https://sp.#{Faker::Internet.domain_name}/shibboleth"
  end

  subject { described_class.new(ds_host) }

  context 'load db config' do
    let(:yml_file) do
      <<-EOF
        a: 1
        b: 2
        c: 3
      EOF
    end

    it 'should read fr_database.yml' do
      allow(File)
        .to receive(:read)
        .with('config/fr_database.yml')
        .and_return(yml_file)

      expect(subject.config).to eq(YAML.load(yml_file))
    end
  end

  context 'establish connection when @config exists' do
    before do
      allow(subject).to receive(:config).and_return(config)

      client.query %(
        CREATE TEMPORARY TABLE IF NOT EXISTS wayf_access_record (
          `id` bigint(20) NOT NULL AUTO_INCREMENT,
          `version` bigint(20) NOT NULL,
          `date_created` datetime DEFAULT NULL,
          `ds_host` varchar(255) NOT NULL,
          `idp_entity` varchar(255) NOT NULL,
          `idpid` bigint(20) NOT NULL,
          `request_type` varchar(255) NOT NULL,
          `robot` bit(1) NOT NULL,
          `source` varchar(255) NOT NULL,
          `sp_endpoint` varchar(255) NOT NULL,
          `spid` bigint(20) NOT NULL,
          PRIMARY KEY (`id`)
        ) AUTO_INCREMENT=10000
      )

      client.query %(
        CREATE TEMPORARY TABLE IF NOT EXISTS spssodescriptor (
          `id` bigint(20) NOT NULL AUTO_INCREMENT,
          `authn_requests_signed` bit(1) NOT NULL,
          `entity_descriptor_id` bigint(20) NOT NULL,
          `service_description_id` bigint(20) NOT NULL,
          `want_assertions_signed` bit(1) NOT NULL,
          `force_attributes_in_filter` bit(1) NOT NULL,
          PRIMARY KEY (`id`)
        ) AUTO_INCREMENT=20000
      )

      client.query %(
        CREATE TEMPORARY TABLE IF NOT EXISTS idpssodescriptor (
          `id` bigint(20) NOT NULL AUTO_INCREMENT,
          `auto_accept_services` bit(1) NOT NULL,
          `collaborator_id` bigint(20) DEFAULT NULL,
          `entity_descriptor_id` bigint(20) NOT NULL,
          `scope` varchar(255) NOT NULL,
          `want_authn_requests_signed` bit(1) NOT NULL,
          `attribute_authority_only` bit(1) NOT NULL,
          PRIMARY KEY (`id`)
        ) AUTO_INCREMENT=30000
      )

      client.query %(
        CREATE TEMPORARY TABLE IF NOT EXISTS entity_descriptor (
          `id` bigint(20) NOT NULL AUTO_INCREMENT,
          `active` bit(1) NOT NULL,
          `approved` bit(1) NOT NULL,
          `archived` bit(1) NOT NULL,
          `date_created` datetime DEFAULT NULL,
          `entityid` varchar(255) NOT NULL,
          `extensions` varchar(2000) DEFAULT NULL,
          `last_updated` datetime DEFAULT NULL,
          `organization_id` bigint(20) NOT NULL,
          PRIMARY KEY (`id`),
          UNIQUE KEY `entityid` (`entityid`)
        ) AUTO_INCREMENT=40000
      )
    end

    def items
      client
        .query('select * from wayf_access_record').to_a.map(&:symbolize_keys)
    end

    def run
      subject.perform
    end

    def last_insert_id
      client.query('SELECT LAST_INSERT_ID() AS id').first['id']
    end

    def create_fr_entity(entity_id)
      client.query %(
        INSERT INTO entity_descriptor
        SET active = 1, approved = 1, archived = 0, organization_id = 0,
            entityid = '#{entity_id}'
      )

      last_insert_id
    end

    def create_fr_idp(entity_id)
      ed_id = create_fr_entity(entity_id)

      client.query %(
        INSERT INTO idpssodescriptor
        SET auto_accept_services = 1, scope = 'example.edu',
            want_authn_requests_signed = 0, attribute_authority_only = 0,
            entity_descriptor_id = #{ed_id}
      )

      last_insert_id
    end

    def create_fr_sp(entity_id)
      ed_id = create_fr_entity(entity_id)

      client.query %(
        INSERT INTO spssodescriptor
        SET authn_requests_signed = 0, service_description_id = 0,
            want_assertions_signed = 1, force_attributes_in_filter = 0,
            entity_descriptor_id = #{ed_id}
      )

      last_insert_id
    end

    def enqueue_event(event)
      redis.lpush('wayf_access_record', JSON.generate(event))
    end

    context 'when an item is pending' do
      let(:selection_method) { 'manual' }

      let(:event) do
        attributes_for(:discovery_service_event, :response,
                       selection_method: selection_method,
                       initiating_sp: initiating_sp,
                       selected_idp: selected_idp)
      end

      let!(:idp_fr_id) { create_fr_idp(selected_idp) }
      let!(:sp_fr_id) { create_fr_sp(initiating_sp) }

      before { enqueue_event(event) }

      def swallow_exception
        yield
      rescue
        nil
      end

      let(:expected_attrs) do
        {
          version: 0,
          date_created: event[:timestamp],
          ds_host: ds_host,
          idp_entity: selected_idp,
          idpid: idp_fr_id,
          request_type: 'DS Request',
          robot: "\x00".b,
          source: event[:ip],
          sp_endpoint: initiating_sp,
          spid: sp_fr_id
        }
      end

      it 'stores the record in the database' do
        expect { run }.to change { items.count }.by(1)
        expect(items.last.except(:id)).to eq(expected_attrs)
      end

      it 'dequeues the item' do
        expect { run }.to change { redis.llen('wayf_access_record') }.to(0)
      end

      context 'when selected by cookie' do
        let(:selection_method) { 'cookie' }

        it 'sets the request_type' do
          run
          expect(items.last[:request_type]).to eq('DS Cookie')
        end
      end

      context 'when the idp is unknown' do
        before do
          client.query('DELETE FROM idpssodescriptor')
        end

        it 'inserts the record with a idpid of -1' do
          expect { run }.to change { items.count }.by(1)
          expect(items.last.except(:id)).to eq(expected_attrs.merge(idpid: -1))
        end

        it 'dequeues the item' do
          expect { run }.to change { redis.llen('wayf_access_record') }.to(0)
        end
      end

      context 'when the sp is unknown' do
        before do
          client.query('DELETE FROM spssodescriptor')
        end

        it 'inserts the record with a spid of -1' do
          expect { run }.to change { items.count }.by(1)
          expect(items.last.except(:id)).to eq(expected_attrs.merge(spid: -1))
        end

        it 'dequeues the item' do
          expect { run }.to change { redis.llen('wayf_access_record') }.to(0)
        end
      end

      context 'when the idp entity_id is missing' do
        let(:event) do
          attributes_for(:discovery_service_event, :response,
                         selection_method: selection_method,
                         initiating_sp: initiating_sp,
                         selected_idp: nil)
        end

        it 'skips the record' do
          expect { run }.not_to change { items.count }
        end

        it 'dequeues the item' do
          expect { run }.to change { redis.llen('wayf_access_record') }.to(0)
        end
      end

      context 'when the idp entity_id is missing' do
        let(:event) do
          attributes_for(:discovery_service_event, :response,
                         selection_method: selection_method,
                         initiating_sp: nil,
                         selected_idp: selected_idp)
        end

        it 'skips the record' do
          expect { run }.not_to change { items.count }
        end

        it 'dequeues the item' do
          expect { run }.to change { redis.llen('wayf_access_record') }.to(0)
        end
      end
    end

    context 'when multiple items are pending' do
      let!(:idps) do
        Array.new(10) do |i|
          "https://idp#{i}.#{Faker::Internet.domain_name}/idp/shibboleth"
            .tap { |entity_id| create_fr_idp(entity_id) }
        end
      end

      let!(:sps) do
        Array.new(10) do |i|
          "https://sp#{i}.#{Faker::Internet.domain_name}/shibboleth"
            .tap { |entity_id| create_fr_sp(entity_id) }
        end
      end

      let(:events) do
        Array.new(100) do
          attributes_for(:discovery_service_event, :response,
                         initiating_sp: sps.sample,
                         selected_idp: idps.sample)
        end
      end

      before { events.each { |e| enqueue_event(e) } }

      it 'stores the records' do
        expect { run }.to change { items.count }.by(100)
          .and change { redis.llen('wayf_access_record') }.to(0)
      end
    end
  end
end
