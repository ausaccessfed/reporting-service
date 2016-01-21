jQuery(function($) {
  var timeFormats = {
    time : d3.time.format('%H:%M'),
    date : d3.time.format('%Y-%m-%d'),
    dateTime : d3.time.format('%Y-%m-%dT%H:%M:%SZ')
  }

  var renderGraph = function(report, target) {
    var sizing = reporting.sizing(report, target);

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
      hoverBoxFormat : timeFormats.date
    }

    var sessionsReportRange = {
      range : report.range,
      timeFormat : timeFormats.dateTime,
      hoverBoxFormat : timeFormats.time
    }

    var dailyDemandReportRange = {
      range : dailyRange,
      timeFormat : timeFormats.time,
      hoverBoxFormat : timeFormats.time
    }

    var rangeSpecs = {
      'federation-growth': defaultRangeArgs,
      'federated-sessions': sessionsReportRange,
      'identity-provider-sessions': sessionsReportRange,
      'daily-demand': dailyDemandReportRange,
      'identity-provider-daily-demand': dailyDemandReportRange
    };

    var scaleRange = reporting.range(rangeSpecs[report.type]);
    var hoverboxTimeformat = rangeSpecs[report.type].hoverBoxFormat;
    var range = reporting.range(defaultRangeArgs);
    var scale = reporting.scale(report, scaleRange, sizing);
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

        svg.call(reporting.axes(scale, sizing))
          .call(reporting.legend(report, sizing))
          .call(reporting.hoverbox(report, scale, scaleRange, sizing, hoverboxTimeformat))
          .call(reporting.labels(report, range, sizing));
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
      'daily-demand': charts.area,
      'identity-provider-daily-demand': charts.area
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

  var renderers = {
    'federation-growth': renderGraph,
    'federated-sessions': renderGraph,
    'identity-provider-sessions': renderGraph,
    'daily-demand': renderGraph,
    'identity-provider-daily-demand': renderGraph,
    'service-compatibility': renderTable,
    'identity-provider-attributes': renderTable,
    'identity-provider-destination-services': renderTable,
    'provided-attribute': renderTable,
    'requested-attribute': renderTable,
    'requested-attribute': renderTable,
  };

  $('.report-data').each(function() {
    var target = $(this).data('target');
    var json = $(this).html();

    if (json) {
      var data = $.parseJSON(json);
      var renderer = renderers[data.type];
      console.log(data.type);
      d3.select(window).on('resize', reporting.throttle(function() {
        renderer(data, target);
      }, 250));

      setTimeout(function() { renderer(data, target); }, 100);
    }
  });
});
