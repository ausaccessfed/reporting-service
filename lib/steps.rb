# frozen_string_literal: true

module Steps
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
    s = start
    f = finish

    return 24 if f >= 1.year.since(s)
    return 12 if f >= 6.months.since(s)
    return 6 if f >= 3.months.since(s)
    return 2 if f >= 1.month.since(s)
    1
  end
end
