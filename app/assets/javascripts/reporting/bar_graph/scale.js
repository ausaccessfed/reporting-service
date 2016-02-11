reporting.barGraph.scale = function(report, range, sizing, barDataIndex) {
  var x = d3.scale.linear()
    .range([0, sizing.graph.width])
    .domain([range.start, range.end]);

  var idPs = report.rows.map(function(row) {
    return row[barDataIndex.idpName];
  });

  var y = d3.scale.ordinal()
    .rangePoints([0, sizing.graph.height])
    .domain(idPs);

  return { x: x, y: y };
};
