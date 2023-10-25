reporting.graph.axes = function (scale, sizing, tickFormat) {
  return function (selection) {
    const { translate } = reporting
    const { graph } = sizing
    const { margin } = graph
    const xTickFormat = typeof tickFormat !== 'undefined' ? tickFormat : null

    const xAxis = d3.svg.axis().scale(scale.x).tickFormat(xTickFormat).orient('bottom').ticks(7)

    selection
      .append('g')
      .attr('class', 'x axis')
      .call(translate(margin.left, margin.top + graph.height))
      .call(xAxis)
      .append('text')
      .call(translate(0, 30))
      .attr('class', 'hover-text x-text')
      .attr('text-anchor', 'middle')

    const yAxis = d3.svg.axis().scale(scale.y).orient('left')

    selection.append('g').attr('class', 'y axis').call(translate(margin.left, margin.top)).call(yAxis)

    selection
      .append('g')
      .attr('class', 'grid')
      .call(translate(margin.left, margin.top))
      .call(xAxis.tickSize(graph.height, 0, 0).tickFormat(''))

    selection
      .append('g')
      .attr('class', 'grid')
      .call(translate(graph.margin.left, graph.margin.top))
      .call(yAxis.tickSize(-graph.width, 0, 0).tickFormat(''))
  }
}
