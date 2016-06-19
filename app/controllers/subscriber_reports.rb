# frozen_string_literal: true
class SubscriberReports < ApplicationController
  before_action { permitted_objects(model_object) }
  before_action :requested_entity
  before_action :set_range_params
  before_action :access_method

  private

  def requested_entity
    return unless params[:entity_id].present?

    @entity = @entities.detect do |entity|
      entity.entity_id == params[:entity_id]
    end
  end

  def output(report_type, steps = nil)
    report = generate_report(report_type, steps)
    JSON.generate(report.generate)
  end

  def generate_report(report_type, steps = nil)
    @entity_id = params[:entity_id]

    return report_type.new(@entity_id, start, finish, steps) if steps
    report_type.new(@entity_id, start, finish)
  end

  def access_method
    return public_action unless params[:entity_id].present?
    check_access! permission_string(@entity)
  end

  def permission_string(entity)
    "objects:organization:#{entity.organization.identifier}:report"
  end

  def permitted_objects(model)
    active_objects = model.preload(:organization).active

    @entities = active_objects.select do |sp|
      subject.permits? permission_string(sp)
    end
  end

  def set_range_params
    @start = params[:start]
    @end = params[:end]
  end

  def start
    return nil if params[:start].blank?
    Time.zone.parse(params[:start]).beginning_of_day
  end

  def finish
    return nil if params[:end].blank?
    Time.zone.parse(params[:end]).tomorrow.beginning_of_day
  end

  def scaled_steps
    range = finish - start

    return 24 if range >= 1.year
    return 12 if range >= 6.months
    return 6 if range >= 3.months
    return 2 if range >= 1.month
    1
  end
end
