reporting.range = {
  'report_range': report_range,
  'daily_range': daily_range
};

function report_range (report) {
  var timeFormat = d3.time.format('%Y-%m-%dT%H:%M:%SZ');
  var range = report.range;

  return {
    start: timeFormat.parse(range.start),
    end: timeFormat.parse(range.end)
  };
};

function daily_range(report) {
  var timeFormat = d3.time.format('%H:%M');

  return {
    start: timeFormat.parse("00:00"),
    end: timeFormat.parse("23:59")
  };
};
