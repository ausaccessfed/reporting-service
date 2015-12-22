reporting.sizing = function(report, target) {
  var container = {
    height: 400,
    width: $(target).width()
  };

  var legend = {
    position: {},
    margin: 20,
    height: report.series.length * 40
  };

  var header = {
    margin: 20
  };

  var margin = {
    top: 45,
    right: 150,
    bottom: 30,
    left: 50
  }

  if (container.width < 720) {
    margin.right = 20;
  }

  var graph = {
    margin: margin,
    height: (container.height - margin.top - margin.bottom),
    width: (container.width - margin.right - margin.left)
  };


  if (container.width < 720) {
    legend.position = {
      x: margin.left,
      y: margin.top + graph.height + margin.bottom
    };
    container.height += legend.height;
  } else {
    legend.position = {
      x: margin.left + graph.width + legend.margin + 10,
      y: margin.top + (graph.height - legend.height) / 2
    };
  }

  return {
    container: container,
    graph: graph,
    legend: legend,
    header: header
  };
};
