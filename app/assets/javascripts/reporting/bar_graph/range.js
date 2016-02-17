reporting.barGraph.range = function (report, barDataIndex) {
  var maxAttributeCount = d3.max(report.rows, function (attributes) {
    var core = parseInt(attributes[barDataIndex.core]);
    var optional = parseInt(attributes[barDataIndex.optional]);
    return d3.max([optional, core]);
  });

  if (maxAttributeCount % 2 != 0) {
    maxAttributeCount++;
  }

  return {
    start: 0,
    end: maxAttributeCount
  };
};
