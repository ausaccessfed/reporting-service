reporting.graph.sizing = function (report, target) {
  const container = {
    height: 400,
    width: $(target).width()
  }

  const legend = {
    position: {},
    margin: 20,
    height: report.series.length * 40
  }

  const header = {
    margin: 20
  }

  const margin = {
    top: 45,
    right: 180,
    bottom: 70,
    left: 65
  }

  if (container.width < 720) {
    margin.right = 20
  }

  const graph = {
    margin,
    height: container.height - margin.top - margin.bottom,
    width: container.width - margin.right - margin.left
  }

  if (container.width < 720) {
    legend.position = {
      x: margin.left,
      y: margin.top + graph.height + margin.bottom
    }
    container.height += legend.height
  } else {
    legend.position = {
      x: margin.left + graph.width + legend.margin + 10,
      y: margin.top + (graph.height - legend.height) / 2
    }
  }

  return {
    container,
    graph,
    legend,
    header
  }
}
