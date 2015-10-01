reporting.range = function(report) {
  var timeFormat = d3.time.format('%Y-%m-%dT%H:%M:%SZ');
  var range = report.range;

  return {
    start: timeFormat.parse(range.start),
    end: timeFormat.parse(range.end)
  };
};
