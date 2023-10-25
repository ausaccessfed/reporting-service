reporting.graph.hoverbox = (report, scale, range, sizing, timeformat) => {
  return (selection) => {
    const timeOnly = timeformat
    const { translate } = reporting
    const { graph } = sizing
    const { margin } = graph
    const g = selection.append('g').call(translate(margin.left, margin.top))

    const hoverbar = g
      .append('line')
      .attr('class', 'hover-bar')
      .attr('x1', 400)
      .attr('x2', 400)
      .attr('y1', 0)
      .attr('y2', graph.height + 20)
      .style('display', 'none')

    const timeText = selection.select('.x-text')

    const bisectDate = d3.bisector((d) => {
      return d[0]
    }).left

    const update = reporting.throttle((mouse) => {
      if (!mouse) {
        report.series.forEach((k) => {
          selection.select(`.legend .${k}-text`).text('')
        })
        selection.select('.x-text').text('')
        return
      }

      let date = 0
      const x0 = (scale.x.invert(mouse[0]) - range.start) / 1000

      report.series.forEach((k) => {
        const data = report.data[k]
        const i = bisectDate(data, x0, 1)
        const d0 = data[i - 1]
        const d1 = i < data.length ? data[i] : d0
        const d = x0 - d0[0] > d1[0] - x0 ? d1 : d0

        date = Math.abs(x0 - d[0]) > Math.abs(x0 - date) ? date : d[0]

        // eslint-disable-next-line no-unused-vars
        const [_, value2, value3] = d
        let value = value2
        if (d.length > 2) value = value3

        selection.select(`.legend .${k}-text`).text(d3.round(value, 2) + report.units)
      })

      selection.select('.x-text').text(timeOnly(d3.time.second.offset(range.start, date)))
    }, 50)

    g.append('rect')
      .attr('class', 'hover-box')
      .attr('width', graph.width)
      .attr('height', graph.height)
      .on('mouseover', () => {
        hoverbar.style('display', null)
      })
      .on('mouseout', () => {
        hoverbar.style('display', 'none')
        update(null)
      })
      .on('mousemove', () => {
        const mouse = d3.mouse(this)
        update(mouse)

        const pos = mouse[0]
        hoverbar.attr('x1', pos).attr('x2', pos)
        timeText.attr('x', pos)
      })
  }
}
