reporting.barHover = function () {
  return d3.select('body')
    .append('div')
    .style('border-radius', '5px')
    .style('position', 'absolute')
    .style('border', '2px solid #73AD21')
    .style('padding', '5px')
    .style('z-index', '10')
    .style('background-color', 'white')
    .style('visibility', 'hidden');
};

reporting.barHoverMouseEvents = function (barHover, type) {
  return function (selection) {
    selection.on('mouseover', function () {
      return barHover.style('visibility', 'visible');
    });

    selection.on('mousemove', function (d) {
      return barHover
        .style('top', (event.pageY - 10) + 'px')
        .style('left', (event.pageX + 10) + 'px')
        .text(type + ': ' + d[1] + ' supported');
    });

    selection.on('mouseout', function () {
      return barHover.style('visibility', 'hidden');
    });

  };
};
