jQuery(function($) {
  var renderGraph = function(report) {
    var sizing = reporting.sizing(report);

    var svg = d3.select('svg' + reporting.selector)
      .attr('class', report.type)
      .attr('height', sizing.container.height)
      .attr('width', sizing.container.width);

    svg.selectAll('svg > *').remove();

    var range = reporting.range(report);
    var scale = reporting.scale(report, range, sizing);
    var translate = reporting.translate;
    var graph = sizing.graph;
    var margin = graph.margin;

    var mappers = {
      x: function(e) { return scale.x(d3.time.second.offset(range.start, e[0])); },
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
          .call(reporting.hoverbox(report, scale, range, sizing))
          .call(reporting.labels(report, range, sizing));
      },

      area: function() {
        var area = d3.svg.area()
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
      'random-time-series': charts.area,
      'random-time-series-line': charts.line
    };

    kinds[report.type]();
  };

  var renderTable = function(report) {
    var table = d3.select('table' + reporting.selector)
      .attr('class', report.type);

    var appendRow = function(parent, row, tag) {
      var tr = parent.append('tr');
      row.forEach(function(field) {
        tr.append(tag).text(field);
      });
    };

    table.selectAll('table > *').remove();

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

  var renderer = {
    'random-time-series': renderGraph,
    'random-time-series-line': renderGraph,
    'random-tabular-data': renderTable
  };

  var json = $('#report-data').html();
  if (json) {
    var data = $.parseJSON(json);
    var target = renderer[data.type];

    d3.select(window).on('resize', reporting.throttle(function() {
      target(data);
    }, 250));

    setTimeout(function() { target(data); }, 0);
  }
});
