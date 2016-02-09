reporting.graph.scale = function(report, range, sizing) {
  var x = d3.time.scale()
    .range([0, sizing.graph.width])
    .domain([range.start, range.end]);

  var yExtents = [];
  var ySelector = function(item) { return item[1]; };

  d3.values(report.data).forEach(function(a) {
    yExtents = yExtents.concat(d3.extent(a, ySelector));
  });

  var domain = d3.extent(yExtents);
  if (domain[0] > 0) domain[0] = 0;

  var y = d3.scale.linear()
    .range([0, sizing.graph.height])
    .domain(domain.reverse());

  return { x: x, y: y };
};
