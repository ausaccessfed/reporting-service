reporting.barRange = function (report, barDataIndex) {
  var maxAttributeCount = d3.max(report.rows, function (attributes) {
    var core = attributes[barDataIndex.core];
    var optional = attributes[barDataIndex.optional];
    return d3.max([optional, core]);
  });

  return {
    start: 0,
    end: maxAttributeCount
  };
};
