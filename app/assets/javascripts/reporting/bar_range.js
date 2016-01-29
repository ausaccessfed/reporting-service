reporting.barRange = function (report) {
  var maxAttributeCount = d3.max(report.rows, function (attributes) {
    var core = attributes[1];
    var optional = attributes[2];
    return d3.max([optional, core]);
  });

  return {
    start: 0,
    end: maxAttributeCount
  };
};
