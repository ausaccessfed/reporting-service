class AutomatedReportInstance < ActiveRecord::Base
  belongs_to :automated_report

  valhammer

  validate :time_must_be_utc_midnight

  private

  def time_must_be_utc_midnight
    t = range_start
    return if t.nil? || [t.gmt_offset, t.hour, t.min, t.sec].all?(&:zero?)

    errors.add(:range_start, 'must be midnight, UTC')
  end
end
