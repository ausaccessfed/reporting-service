#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.setup

require 'yaml'
require 'English'
require 'mysql2'
require 'redis'
require 'implicit-schema'

class PushEventsToFederationRegistry
  def self.squeeze_sql(sql)
    sql.lines.map(&:chomp).join(' ').squeeze(' ').strip.freeze
  end

  def initialize(hostname)
    @hostname = hostname
  end

  PENDING_QUEUE = 'wayf_access_record:pending'.freeze
  QUEUE = 'wayf_access_record'.freeze

  def perform
    loop do
      json = redis.rpoplpush(QUEUE, PENDING_QUEUE)
      break unless json
      event = ImplicitSchema.new(JSON.parse(json, symbolize_names: true))

      insert_record(event)
      redis.ltrim(PENDING_QUEUE, 1, -1)
    end
  ensure
    nil while redis.rpoplpush(PENDING_QUEUE, QUEUE)
  end

  def mysql_client
    @client ||= Mysql2::Client.new(config.merge(database_timezone: :utc))
  end

  def config
    @config ||= YAML.load(File.read('config/fr_database.yml'))
  end

  private

  def redis
    @redis ||= Redis.new
  end

  INSERT_SQL = squeeze_sql %(
    INSERT INTO wayf_access_record
    SET version = 0,
        robot = 0,
        date_created = '%<date_created>s',
        ds_host = '%<hostname>s',
        idp_entity = '%<idp_entity>s',
        idpid = %<idpid>d,
        request_type = '%<request_type>s',
        source = '%<source>s',
        sp_endpoint = '%<sp_endpoint>s',
        spid = %<spid>d
  )

  def insert_record(event)
    sql = format(INSERT_SQL, convert(event))
    mysql_client.query(sql)
  end

  def convert(event)
    {
      date_created: Time.zone.parse(event[:timestamp]).utc.to_s(:db),
      hostname: e(@hostname),
      idp_entity: event[:selected_idp],
      idpid: resolve_idpid(event),
      request_type: convert_request_type(event),
      source: event[:ip],
      sp_endpoint: event[:initiating_sp],
      spid: resolve_spid(event)
    }
  end

  RESOLVE_IDPID_SQL = squeeze_sql %(
    SELECT idp.id
    FROM idpssodescriptor idp
    JOIN entity_descriptor ed
      ON idp.entity_descriptor_id = ed.id
    WHERE ed.entityid = '%s'
  )

  def resolve_idpid(event)
    sql = format(RESOLVE_IDPID_SQL, e(event[:selected_idp]))
    result = mysql_client.query(sql).first
    return result['id'] if result
    fail("No such IdP found in FR database: #{event[:selected_idp]}\n\n#{sql}")
  end

  RESOLVE_SPID_SQL = squeeze_sql %(
    SELECT sp.id
    FROM spssodescriptor sp
    JOIN entity_descriptor ed
      ON sp.entity_descriptor_id = ed.id
    WHERE ed.entityid = '%s'
  )

  def resolve_spid(event)
    sql = format(RESOLVE_SPID_SQL, e(event[:initiating_sp]))
    result = mysql_client.query(sql).first
    return result['id'] if result
    fail("No such SP found in FR database: #{event[:initiating_sp]}\n\n#{sql}")
  end

  def convert_request_type(event)
    if event[:selection_method] == 'cookie'
      'DS Cookie'
    else
      'DS Request'
    end
  end

  def e(value)
    mysql_client.escape(value)
  end
end

PushEventsToFederationRegistry.new(*ARGV).perform if $PROGRAM_NAME == __FILE__
