reporting.graph.range = function (rangeSpecs) {
  return {
    start: rangeSpecs.timeFormat.parse(rangeSpecs.range.start),
    end: rangeSpecs.timeFormat.parse(rangeSpecs.range.end)
  };
};
