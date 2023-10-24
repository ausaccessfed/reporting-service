reporting.graph.scale = (report, range, sizing) => {
  const x = d3.time.scale().range([0, sizing.graph.width]).domain([range.start, range.end])

  let yExtents = []
  const ySelector = (item) => {
    return item[1]
  }

  d3.values(report.data).forEach((a) => {
    yExtents = yExtents.concat(d3.extent(a, ySelector))
  })

  const domain = d3.extent(yExtents)
  if (domain[0] > 0) domain[0] = 0
  if (domain[domain.length - 1] === 0) domain[1] = 1

  const y = d3.scale.linear().range([0, sizing.graph.height]).domain(domain.reverse())

  return { x, y }
}
