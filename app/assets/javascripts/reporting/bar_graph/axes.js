reporting.barGraph.axes = function(scale, sizing) {
  return function(selection) {
    var translate = reporting.translate;
    var xAxis = d3.svg.axis()
      .orient('bottom')
      .tickSize(-sizing.graph.height - sizing.bar.height * 2, 0, 0)
      .scale(scale.x);

    var yAxis = d3.svg.axis()
      .orient('left')
      .scale(scale.y);

    var xAxisPosition = sizing.graph.height + sizing.margin.top +
      (sizing.bar.height * 2);

    selection.append('g')
      .attr('class', 'axis')
      .attr('width', sizing.graph.width)
      .attr('height', sizing.graph.height)
      .call(translate(sizing.margin.left, xAxisPosition))
      .call(xAxis);

    selection.append('text')
      .call(translate(sizing.margin.left + sizing.graph.width / 2,
        xAxisPosition + sizing.xAxisLabel.marginTop))
      .attr('class', 'label')
      .attr('text-anchor', 'middle')
      .text('Supported Attributes');

    selection.append('g')
      .attr('class', 'axis')
      .attr('width', sizing.graph.width)
      .attr('height', sizing.graph.height)
      .call(translate(sizing.margin.left,
        sizing.margin.top + sizing.bar.height))
      .call(yAxis);
  };
};
