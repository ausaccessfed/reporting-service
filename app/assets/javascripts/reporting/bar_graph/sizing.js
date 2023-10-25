reporting.barGraph.sizing = function (report, target) {
  const bar = {
    height: 10
  }

  const row = {
    height: bar.height * 4
  }

  const xAxisLabel = {
    marginTop: 40,
    marginBottom: 20
  }

  const margin = {
    top: 40,
    right: 40,
    bottom: 40,
    left: 260
  }

  const hoverPointerOffset = {
    x: 10,
    y: 10
  }

  const graph = {
    height: report.rows.length * row.height,
    width: $(target).width() - margin.right - margin.left
  }

  const container = {
    height: graph.height + margin.top + margin.bottom + xAxisLabel.marginTop + xAxisLabel.marginBottom,
    width: $(target).width()
  }

  return {
    container,
    graph,
    bar,
    xAxisLabel,
    hoverPointerOffset,
    margin
  }
}
