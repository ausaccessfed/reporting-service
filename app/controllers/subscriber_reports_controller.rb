class SubscriberReportsController < ApplicationController
  before_action { permitted_objects(model_object) }
  before_action :requested_entity
  before_action :access_method

  private

  def requested_entity
    return unless params[:entity_id].present?

    @entity = @entities.detect do |entity|
      entity.entity_id == params[:entity_id]
    end
  end

  def data_output(report_type, step = nil)
    report = generate_report(report_type, step)
    JSON.generate(report.generate)
  end

  def generate_report(report_type, step = nil)
    @start = Time.zone.parse(params[:start])
    @end = Time.zone.parse(params[:end])
    @entity_id = params[:entity_id]

    return report_type.new(@entity_id, @start, @end, step) if step
    report_type.new(@entity_id, @start, @end)
  end

  def access_method
    return public_action unless params[:entity_id].present?
    check_access! permission_string(@entity)
  end

  def permission_string(entity)
    "objects:organization:#{entity.organization.identifier}:report"
  end

  def permitted_objects(model)
    active_sps = model.preload(:organization).active

    @entities = active_sps.select do |sp|
      subject.permits? permission_string(sp)
    end
  end
end
