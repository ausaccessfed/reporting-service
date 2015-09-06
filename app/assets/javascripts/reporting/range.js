reporting.range = function(report) {
  var timeFormat = d3.time.format('%Y-%m-%d %H:%M:%S UTC');
  var range = report.range;

  return {
    start: timeFormat.parse(range.start),
    end: timeFormat.parse(range.end)
  };
};
