class AutomatedReportInstancesController < AutomatedReports
  before_action :set_access_method

  def show
    @instance = instance
    report = @instance.materialize.generate
    @data = JSON.generate(report)
  end

  private

  def instance
    AutomatedReportInstance.find_by(identifier: params[:identifier])
  end

  def report_class
    instance.automated_report.report_class
  end

  def entity
    instance.automated_report.target_object
  end
end
