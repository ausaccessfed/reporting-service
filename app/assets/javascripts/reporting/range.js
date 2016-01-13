reporting.range = function (range, timeFormat) {
  return {
    start: timeFormat.parse(range.start),
    end: timeFormat.parse(range.end)
  };
};
