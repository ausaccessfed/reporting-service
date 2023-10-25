jQuery(function renderReport($) {
  const timeFormats = {
    time: d3.time.format('%H:%M'),
    date: d3.time.format('%Y-%m-%d'),
    dateTime: d3.time.format('%Y-%m-%dT%H:%M:%S%Z'),
    facncyDateTime: d3.time.format('%Y-%m-%d ~ %H:%M'),
    fancyTickFormat: d3.time.format('%H')
  }

  function renderGraph(report, target) {
    const sizing = reporting.graph.sizing(report, target)

    const svg = d3.select(target).selectAll('svg').data([reporting.id])

    svg.selectAll('svg > *').remove()

    svg
      .enter()
      .append('svg')
      .attr('id', (id) => id)
      .attr('class', `${report.type} report-output`)

    svg.attr('height', sizing.container.height).attr('width', sizing.container.width)

    const dailyRange = { start: '00:00', end: '23:59' }

    const defaultRangeArgs = {
      range: report.range,
      timeFormat: timeFormats.dateTime,
      hoverBoxFormat: timeFormats.date,
      tickFormat: null
    }

    const sessionsReportRange = {
      range: report.range,
      timeFormat: timeFormats.dateTime,
      hoverBoxFormat: timeFormats.facncyDateTime,
      tickFormat: null
    }

    const dailyDemandReportRange = {
      range: dailyRange,
      timeFormat: timeFormats.time,
      hoverBoxFormat: timeFormats.time,
      tickFormat: timeFormats.fancyTickFormat
    }

    const rangeSpecs = {
      'federation-growth': defaultRangeArgs,
      'federated-sessions': sessionsReportRange,
      'identity-provider-sessions': sessionsReportRange,
      'service-provider-sessions': sessionsReportRange,
      'daily-demand': dailyDemandReportRange,
      'identity-provider-daily-demand': dailyDemandReportRange,
      'service-provider-daily-demand': dailyDemandReportRange
    }

    const scaleRange = reporting.graph.range(rangeSpecs[report.type])
    const hoverboxTimeformat = rangeSpecs[report.type].hoverBoxFormat
    const axesTickFormat = rangeSpecs[report.type].tickFormat
    const range = reporting.graph.range(defaultRangeArgs)
    const scale = reporting.graph.scale(report, scaleRange, sizing)
    const { translate } = reporting
    const { graph } = sizing
    const { margin } = graph

    const mappers = {
      x(e) {
        return scale.x(d3.time.second.offset(scaleRange.start, e[0]))
      },
      y(e) {
        return scale.y(e[1])
      }
    }

    const charts = {
      generic(type, d) {
        const g = svg.append('g').attr('class', `${type} paths`).call(translate(margin.left, margin.top))

        report.series.forEach(function seriesAdd(key) {
          g.append('path').datum(report.data[key]).attr('class', key).attr('d', d)
        })

        svg
          .call(reporting.graph.axes(scale, sizing, axesTickFormat))
          .call(reporting.graph.legend(report, sizing))
          .call(reporting.graph.hoverbox(report, scale, scaleRange, sizing, hoverboxTimeformat))
          .call(reporting.graph.labels(report, range, sizing))
      },

      area() {
        const area = d3.svg.area().interpolate('step').x(mappers.x).y0(graph.height).y1(mappers.y)

        charts.generic('area', area)
      },

      line() {
        const line = d3.svg.line().x(mappers.x).y(mappers.y)

        charts.generic('line', line)
      }
    }

    const kinds = {
      'federation-growth': charts.area,
      'federated-sessions': charts.area,
      'identity-provider-sessions': charts.area,
      'service-provider-sessions': charts.area,
      'daily-demand': charts.area,
      'identity-provider-daily-demand': charts.area,
      'service-provider-daily-demand': charts.area
    }

    kinds[report.type]()
  }

  function renderTable(report, target) {
    const table = d3.select(target).selectAll('table').data([reporting.id])
    table.selectAll('table > *').remove()

    table
      .enter()
      .append('table')
      .attr('id', (id) => id)
      .attr('class', `${report.type} report-output table table-hover`)

    function appendRow(parent, row, tag) {
      const tr = parent.append('tr')
      row.forEach((field) => {
        tr.append(tag).text(field)
      })
    }

    const prettyDateFormat = d3.time.format('%d/%m/%Y')

    const thead = table.append('thead')
    const tbody = table.append('tbody')
    const tfoot = table.append('tfoot')

    report.header.forEach((row) => {
      appendRow(thead, row, 'th')
    })

    report.rows.forEach((row) => {
      if (report.type === 'subscriber-registrations') {
        row[1] = prettyDateFormat(new Date(row[1]))
      }

      appendRow(tbody, row, 'td')
    })

    report.footer.forEach((row) => {
      appendRow(tfoot, row, 'td')
    })
  }

  function renderBarGraph(report, target) {
    const barDataIndex = reporting.barGraph.dataIndex()
    const range = reporting.barGraph.range(report, barDataIndex)
    const sizing = reporting.barGraph.sizing(report, target)
    const scale = reporting.barGraph.scale(report, range, sizing, barDataIndex)
    const { translate } = reporting

    const svg = d3.select(target).selectAll('svg').data([reporting.id])

    svg.selectAll('svg > *').remove()

    svg
      .enter()
      .append('svg')
      .attr('id', (id) => id)
      .attr('class', `${report.type} report-output`)
      .attr('height', sizing.container.height)
      .attr('width', '100%')

    svg.call(reporting.barGraph.axes(scale, sizing))

    const rect = svg
      .append('g')
      .call(translate(sizing.margin.left, sizing.margin.top))
      .selectAll('rect')
      .data(report.rows)
      .enter()

    const barHover = d3.select('body').append('div').attr('class', 'bar-hover')

    rect
      .append('rect')
      .attr('y', (data) => {
        return scale.y(data[barDataIndex.idpName])
      })
      .attr('width', (data) => {
        return scale.x(data[barDataIndex.core])
      })
      .attr('height', sizing.bar.height)
      .attr('class', 'core-bar')
      .call(reporting.barGraph.hover(barHover, sizing, barDataIndex, 'core'))

    rect
      .append('rect')
      .attr('y', (data) => {
        return scale.y(data[barDataIndex.idpName]) + sizing.bar.height
      })
      .attr('width', (data) => {
        return scale.x(data[barDataIndex.optional])
      })
      .attr('height', sizing.bar.height)
      .attr('class', 'optional-bar')
      .call(reporting.barGraph.hover(barHover, sizing, barDataIndex, 'optional'))
  }

  const renderers = {
    'federation-growth': renderGraph,
    'federated-sessions': renderGraph,
    'identity-provider-sessions': renderGraph,
    'service-provider-sessions': renderGraph,
    'daily-demand': renderGraph,
    'identity-provider-daily-demand': renderGraph,
    'service-provider-daily-demand': renderGraph,
    'service-compatibility': renderTable,
    'identity-provider-destination-services': renderTable,
    'service-provider-source-identity-providers': renderTable,
    'identity-provider-attributes': renderBarGraph,
    'provided-attribute': renderTable,
    'requested-attribute': renderTable,
    'subscriber-registrations': renderTable,
    'identity-provider-utilization': renderTable,
    'service-provider-utilization': renderTable
  }

  $('.report-data').each(function eachReport() {
    const target = $(this).data('target')
    const json = $(this).html()

    if (json) {
      const data = $.parseJSON(json)
      const renderer = renderers[data.type]

      d3.select(window).on(
        'resize',
        reporting.throttle(() => {
          renderer(data, target)
        }, 250)
      )

      d3.select(window).on('load', () => {
        renderer(data, target)
      })
    }
  })
})
