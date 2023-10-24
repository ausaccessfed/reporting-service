reporting.barGraph.range = (report, barDataIndex) => {
  let maxAttributeCount = d3.max(report.rows, (attributes) => {
    const core = parseInt(attributes[barDataIndex.core], 2)
    const optional = parseInt(attributes[barDataIndex.optional], 2)
    return d3.max([optional, core])
  })

  if (maxAttributeCount % 2 !== 0) {
    maxAttributeCount++
  }

  return {
    start: 0,
    end: maxAttributeCount
  }
}
