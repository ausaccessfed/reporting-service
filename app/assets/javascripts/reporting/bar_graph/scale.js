reporting.barGraph.scale = function (report, range, sizing, barDataIndex) {
  const x = d3.scale.linear().range([0, sizing.graph.width]).domain([range.start, range.end])

  const idPs = report.rows.map(function (row) {
    return row[barDataIndex.idpName]
  })

  const y = d3.scale.ordinal().rangePoints([0, sizing.graph.height]).domain(idPs)

  return { x, y }
}
