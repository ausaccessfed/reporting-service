reporting.barGraph.sizing = function(report, target) {
  var bar = {
    height: 10
  };

  var row = {
    height: bar.height * 4
  };

  var xAxisLabel = {
    marginTop: 40,
    marginBottom: 20
  };

  var margin = {
    top: 40,
    right: 40,
    bottom: 40,
    left: 260
  };

  var hoverPointerOffset = {
    x: 10,
    y: 10
  };

  var graph = {
    height: report.rows.length * row.height,
    width: $(target).width() - margin.right - margin.left
  };

  var container = {
    height: graph.height + margin.top + margin.bottom +
      xAxisLabel.marginTop + xAxisLabel.marginBottom,
    width: $(target).width()
  };

  return {
    container: container,
    graph: graph,
    bar: bar,
    xAxisLabel: xAxisLabel,
    hoverPointerOffset: hoverPointerOffset,
    margin: margin
  };
};
