jQuery(function($) {
  var timeFormats = {
    time : d3.time.format('%H:%M'),
    date : d3.time.format('%Y-%m-%d'),
    dateTime : d3.time.format('%Y-%m-%dT%H:%M:%SZ'),
    facncyDateTime : d3.time.format('%Y-%m-%d ~ %H:%M'),
    fancyTickFormat : d3.time.format("%H")
  }

  var renderGraph = function(report, target) {
    var sizing = reporting.graph.sizing(report, target);

    var svg = d3.select(target)
      .selectAll('svg')
      .data([reporting.id]);

    svg.selectAll('svg > *').remove();

    svg.enter()
      .append('svg')
      .attr('id', function(id) { return id; })
      .attr('class', report.type + ' report-output');

    svg.attr('height', sizing.container.height)
      .attr('width', sizing.container.width);

    var dailyRange = { start: "00:00", end: "23:59" };

    var defaultRangeArgs = {
      range : report.range,
      timeFormat : timeFormats.dateTime,
      hoverBoxFormat : timeFormats.date,
      tickFormat : null
    }

    var sessionsReportRange = {
      range : report.range,
      timeFormat : timeFormats.dateTime,
      hoverBoxFormat : timeFormats.facncyDateTime,
      tickFormat : null
    }

    var dailyDemandReportRange = {
      range : dailyRange,
      timeFormat : timeFormats.time,
      hoverBoxFormat : timeFormats.time,
      tickFormat : timeFormats.fancyTickFormat
    }

    var rangeSpecs = {
      'federation-growth': defaultRangeArgs,
      'federated-sessions': sessionsReportRange,
      'identity-provider-sessions': sessionsReportRange,
      'service-provider-sessions': sessionsReportRange,
      'daily-demand': dailyDemandReportRange,
      'identity-provider-daily-demand': dailyDemandReportRange,
      'service-provider-daily-demand': dailyDemandReportRange
    };

    var scaleRange = reporting.graph.range(rangeSpecs[report.type]);
    var hoverboxTimeformat = rangeSpecs[report.type].hoverBoxFormat;
    var axesTickFormat = rangeSpecs[report.type].tickFormat;
    var range = reporting.graph.range(defaultRangeArgs);
    var scale = reporting.graph.scale(report, scaleRange, sizing);
    var translate = reporting.translate;
    var graph = sizing.graph;
    var margin = graph.margin;

    var mappers = {
      x: function(e) { return scale.x(d3.time.second.offset(scaleRange.start, e[0])); },
      y: function(e) { return scale.y(e[1]); }
    };

    var charts = {
      generic: function(type, d) {
        var g = svg.append('g')
          .attr('class', type + ' paths')
          .call(translate(margin.left, margin.top))

        report.series.forEach(function(key) {
          g.append('path')
            .datum(report.data[key])
            .attr('class', key)
            .attr('d', d);
        });

        svg.call(reporting.graph.axes(scale, sizing, axesTickFormat))
          .call(reporting.graph.legend(report, sizing))
          .call(reporting.graph.hoverbox(report, scale, scaleRange, sizing, hoverboxTimeformat))
          .call(reporting.graph.labels(report, range, sizing));
      },

      area: function() {
        var area = d3.svg.area()
          .interpolate('step')
          .x(mappers.x)
          .y0(graph.height)
          .y1(mappers.y);

        charts.generic('area', area);
      },

      line: function() {
        var line = d3.svg.line()
          .x(mappers.x)
          .y(mappers.y);

        charts.generic('line', line);
      }
    };

    var kinds = {
      'federation-growth': charts.area,
      'federated-sessions': charts.area,
      'identity-provider-sessions': charts.area,
      'service-provider-sessions': charts.area,
      'daily-demand': charts.area,
      'identity-provider-daily-demand': charts.area,
      'service-provider-daily-demand': charts.area
    };

    kinds[report.type]();
  };

  var renderTable = function(report, target) {
    var table = d3.select(target)
      .selectAll('table')
      .data([reporting.id]);
    table.selectAll('table > *').remove();

    table.enter()
      .append('table')
      .attr('id', function(id) { return id; })
      .attr('class', report.type + ' report-output');

    var appendRow = function(parent, row, tag) {
      var tr = parent.append('tr');
      row.forEach(function(field) {
        tr.append(tag).text(field);
      });
    };

    var thead = table.append('thead');
    var tbody = table.append('tbody');
    var tfoot = table.append('tfoot');

    report.header.forEach(function(row) {
      appendRow(thead, row, 'th');
    });

    report.rows.forEach(function(row) {
      appendRow(tbody, row, 'td');
    });

    report.footer.forEach(function(row) {
      appendRow(tfoot, row, 'td');
    });
  };

  var renderBarGraph = function (report, target) {
    var barDataIndex = reporting.barGraph.dataIndex();
    var range = reporting.barGraph.range(report, barDataIndex);
    var sizing = reporting.barGraph.sizing(report, target);
    var scale = reporting.barGraph.scale(report, range, sizing, barDataIndex);
    var translate = reporting.translate;

    var svg = d3.select(target)
      .selectAll('svg')
        .data([reporting.id]);

    svg.selectAll('svg > *')
      .remove();

    svg.enter()
      .append('svg')
        .attr('id', function (id) { return id; })
        .attr('class', report.type + ' report-output')
        .attr('height', sizing.container.height)
        .attr('width', '100%');

    svg.call(reporting.barGraph.axes(scale, sizing));

    var rect = svg.append('g')
      .call(translate(sizing.margin.left, sizing.margin.top))
      .selectAll('rect')
        .data(report.rows)
      .enter();

    var barHover = d3.select('body')
      .append('div')
      .attr('class', 'bar-hover');

    rect.append('rect')
      .attr('y', function (data) {
        return scale.y(data[barDataIndex.idpName])
      })
      .attr('width', function (data) {
        return scale.x(data[barDataIndex.core])
      })
      .attr('height', sizing.bar.height)
      .attr('class', 'core-bar')
      .call(reporting.barGraph.hover(barHover, sizing, barDataIndex, 'core'));

    rect.append('rect')
      .attr('y', function (data) {
        return scale.y(data[barDataIndex.idpName]) + sizing.bar.height
      })
      .attr('width', function (data) {
        return scale.x(data[barDataIndex.optional])
      })
      .attr('height', sizing.bar.height)
      .attr('class', 'optional-bar')
      .call(reporting.barGraph.hover(barHover, sizing, barDataIndex, 'optional'));
  };

  var renderers = {
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
    'subscriber-registrations': renderTable
  };

  $('.report-data').each(function() {
    var target = $(this).data('target');
    var json = $(this).html();

    if (json) {
      var data = $.parseJSON(json);
      var renderer = renderers[data.type];

      d3.select(window).on('resize', reporting.throttle(function() {
        renderer(data, target);
      }, 250));

      setTimeout(function() { renderer(data, target); }, 100);
    }
  });
});
