reporting.graph.labels = function(report, range, sizing) {
  return function(selection) {
    var translate = reporting.translate;
    var graph = sizing.graph;
    var margin = graph.margin;
    var prettyDateFormat = d3.time.format('%-d %b %Y');

    var g = selection.append('g')
      .call(translate(margin.left, sizing.header.margin));

    g.append('text')
      .call(translate(graph.width / 2, 0))
      .attr('class', 'label title')
      .attr('text-anchor', 'middle')
      .text(report.title);

    g.append('text')
      .call(translate(graph.width / 2, 15))
      .attr('class', 'label subtitle')
      .attr('text-anchor', 'middle')
      .text(prettyDateFormat(range.start) + " \u2014 " + prettyDateFormat(range.end));

    var y = selection.append('g')
      .call(translate(0, margin.top))
      .append('text')
      .attr('class', 'label y-axis')
      .attr('text-anchor', 'middle')
      .call(translate(15, graph.height / 2))
      .text(report.labels.y);

    y.attr('transform', y.attr('transform') + ', rotate(-90)');

    var x = selection.append('g')
      .call(translate(margin.left, margin.top + graph.height))
      .append('text')
      .call(translate(sizing.graph.width / 2, 50))
      .attr('class', 'label axis')
      .attr('text-anchor', 'middle')
      .text('Time')

  };
};
