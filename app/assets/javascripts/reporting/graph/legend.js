reporting.graph.legend = function(report, sizing) {
  return function(selection) {
    var translate = reporting.translate;
    var pos = sizing.legend.position;
    var offset = 20;

    var g = selection.append('g')
      .attr('class', 'legend ' + report.type)
      .call(translate(pos.x, pos.y));

    report.series.forEach(function(key) {
      g.append('text')
        .call(translate(20, offset))
        .text(key);

      g.append('rect')
        .attr('class', key)
        .attr('width', 15)
        .attr('height', 15)
        .call(translate(0, offset - 13));

      g.append('text')
        .call(translate(20, offset + 17))
        .attr('class', 'hover-text ' + key + '-text');

      offset += 40;
    });
  };
};
