# frozen_string_literal: true

module ReportsSharedMethods
  def source_options
    SESSION_SOURCES.map { |k, v| [v[:name], k] }
  end

  def source_display_names
    SESSION_SOURCES.transform_values { |v| v[:name] }.merge(nil => 'N/A')
  end
  module_function :source_options, :source_display_names

  def source_name
    SESSION_SOURCES[@source][:name]
  end

  private

  def output_data(range, report, step_width, divider, decimal_places = 1)
    range.step(step_width).each_with_object(sessions: []) do |t, data|
      average = average report, t, divider, decimal_places

      data[:sessions] << [t, average]
    end
  end

  def per_hour_output(default_sessions = sessions)
    report = sessions_count(default_sessions) do |session|
      offset = session - @start
      offset - (offset % @steps.hour.to_i)
    end

    output_data range, report, @steps.hours, @steps
  end

  def daily_demand_output(default_sessions = sessions)
    report = sessions_count(default_sessions) do |session|
      offset = (session - session.beginning_of_day).to_i
      offset - (offset % 5.minutes)
    end

    output_data 0..86_340, report, 5.minutes, days_count, 2
  end

  def range
    (0..(@finish - @start).to_i)
  end

  def sessions_count(sessions)
    sessions.pluck(:timestamp).each_with_object({}) do |session, data|
      point = yield session
      (data[point.to_i] ||= 0) << data[point.to_i] += 1
    end
  end

  def days_count
    (@start.to_i..@finish.to_i).step(1.day).size
  end

  def average(report, time, divider, decimal_places = 1)
    report[time] ? (report[time].to_f / divider).round(decimal_places) : 0.0
  end

  SESSION_SOURCES = {
    'DS' => { klass: DiscoveryServiceEvent,
              name: 'Discovery Service',
              idp: 'selected_idp', sp: 'initiating_sp' },
    'IdP' => { klass: FederatedLoginEvent,
               name: 'IdP Event Log',
               idp: 'asserting_party', sp: 'relying_party' }
  }.freeze

  def sessions(where_args = {})
    SESSION_SOURCES[@source][:klass]
      .within_range(@start, @finish).where(where_args).sessions
  end

  def idp_sessions
    sessions(SESSION_SOURCES[@source][:idp] => @identity_provider.entity_id)
  end

  def sp_sessions
    sessions(SESSION_SOURCES[@source][:sp] => @service_provider.entity_id)
  end

  def tabular_sessions(target, session_objects = sessions)
    sql = tabular_sessions_query(target, session_objects)

    target.connection.execute(sql)
          .map { |a| a.map(&:to_s) }
          .sort_by { |a| a[0].downcase }
  end

  TARGET_OPTS = {
    IdentityProvider => {
      assoc: :identity_provider,
      foreign_key: { 'DS' => 'selected_idp', 'IdP' => 'asserting_party' }.freeze
    }.freeze,
    ServiceProvider => {
      assoc: :service_provider,
      foreign_key: { 'DS' => 'initiating_sp', 'IdP' => 'relying_party' }.freeze
    }.freeze
  }.freeze

  def tabular_sessions_query(target, session_objects)
    opts = TARGET_OPTS[target]

    session_objects
      .joins(opts[:assoc])
      .group(opts[:foreign_key][@source])
      .select(target.arel_table[:name], 'count(*)')
      .to_sql
  end
end
