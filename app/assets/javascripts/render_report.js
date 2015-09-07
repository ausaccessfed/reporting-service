jQuery(function($) {
  var renderReport = function(report) {
    var sizing = reporting.sizing(report);

    var svg = d3.select('svg' + reporting.selector)
      .attr('class', report.type)
      .attr('height', sizing.container.height)
      .attr('width', sizing.container.width);

    svg.selectAll('svg > *').remove();

    var range = reporting.range(report);
    var scale = reporting.scale(report, range, sizing);
    var translate = reporting.translate;

    var charts = {
      area: function() {
        var area = d3.svg.area()
          .x(function(e) { return scale.x(d3.time.second.offset(range.start, e[0])); })
          .y0(sizing.graph.height)
          .y1(function(e) { return scale.y(e[1]); });

        var g = svg.append('g')
          .attr('class', 'area paths')
          .call(translate(sizing.graph.margin.left, sizing.graph.margin.top));

        d3.entries(report.data).forEach(function(entry) {
          g.append('path')
            .datum(entry.value)
            .attr('class', entry.key)
            .attr('d', area);
        });

        svg.call(reporting.axes(scale, sizing))
          .call(reporting.legend(report, sizing))
          .call(reporting.hoverbox(report, scale, range, sizing))
          .call(reporting.labels(report, range, sizing));
      }
    };

    charts.area();
  };

  var json = $('#report-data').html();
  if (json) {
    var data = $.parseJSON(json);

    d3.select(window).on('resize', reporting.throttle(function() {
      renderReport(data);
    }, 250));

    renderReport(data);
  }
});
