reporting.hoverbox = function(report, scale, range, sizing, timeformat) {
  return function(selection) {
    var timeOnly = timeformat;
    var translate = reporting.translate;
    var graph = sizing.graph;
    var margin = graph.margin;
    var g = selection.append('g')
      .call(translate(margin.left, margin.top));

    var hoverbar = g.append('line')
      .attr('class', 'hover-bar')
      .attr('x1', 400)
      .attr('x2', 400)
      .attr('y1', 0)
      .attr('y2', graph.height + 20)
      .style('display', 'none');

    var timeText = selection.select('.x-text');

    var bisectDate = d3.bisector(function(d) { return d[0]; }).left;

    var update = reporting.throttle(function(mouse) {
      if (!mouse) {
        report.series.forEach(function(k) {
          selection.select('.legend .' + k + '-text').text('');
        });
        selection.select('.x-text').text('');
        return;
      }

      var date = 0;
      var x0 = (scale.x.invert(mouse[0]) - range.start) / 1000;

      report.series.forEach(function(k) {
        var data = report.data[k];
        var i = bisectDate(data, x0, 1);
        var d0 = data[i - 1];
        var d1 = data[i];
        var d = x0 - d0[0] > d1[0] - x0 ? d1 : d0;

        date = Math.abs(x0 - d[0]) > Math.abs(x0 - date) ? date : d[0];

        var value = d[1];
        if (d.length > 2) value = d[2];

        selection.select('.legend .' + k + '-text')
          .text(d3.round(value, 1) + report.units);
      });

      selection.select('.x-text').text(
        timeOnly(d3.time.second.offset(range.start, date))
      );
    }, 50);

    g.append('rect')
      .attr('class', 'hover-box')
      .attr('width', graph.width)
      .attr('height', graph.height)
      .on('mouseover', function() {
        hoverbar.style('display', null);
      })
      .on('mouseout', function() {
        hoverbar.style('display', 'none');
        update(null);
      })
      .on('mousemove', function() {
        var mouse = d3.mouse(this);
        update(mouse);

        var pos = mouse[0];
        hoverbar.attr('x1', pos).attr('x2', pos);
        timeText.attr('x', pos);
      });
  };
};
