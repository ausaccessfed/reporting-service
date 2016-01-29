reporting.barSizing = function(report, target) {
  var bar = {
    height: 10
  };

  var row = {
    height: bar.height * 4
  };

  var margin = {
    top: 40,
    right: 40,
    bottom: 40,
    left: 160
  };

  var graph = {
    height: report.rows.length * row.height,
    width: $(target).width() - margin.right - margin.left
  };

  var container = {
    height: graph.height + margin.top + margin.bottom,
    width: $(target).width()
  };

  return {
    container: container,
    graph: graph,
    bar: bar,
    margin: margin
  };
};
