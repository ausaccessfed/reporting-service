reporting.graph.legend = function (report, sizing) {
  return function (selection) {
    const { translate } = reporting
    const pos = sizing.legend.position
    let offset = 20

    const g = selection.append('g').attr('class', `legend ${report.type}`).call(translate(pos.x, pos.y))

    report.series.forEach(function (key) {
      g.append('text').call(translate(20, offset)).text(report.labels[key])

      g.append('rect')
        .attr('class', key)
        .attr('width', 15)
        .attr('height', 15)
        .call(translate(0, offset - 13))

      g.append('text')
        .call(translate(20, offset + 17))
        .attr('class', `hover-text ${key}-text`)

      offset += 40
    })
  }
}
