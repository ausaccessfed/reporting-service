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
    range = range(start, finish)

    return 24 if range >= 1.year
    return 12 if range >= 6.months
    return 6 if range >= 3.months
    return 2 if range >= 1.month
    1
  end

  def range(start, finish)
    range = finish - start

    # February could have less days, therefore offset
    range += 2.days if (start.month..finish.month).cover?(2)

    range
  end
end
