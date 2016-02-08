reporting.barHover = function (barHover, type, borderStyle) {
  return function (selection) {
    selection.on('mouseover', function () {
      return barHover.style('visibility', 'visible');
    });

    selection.on('mousemove', function (d) {
      return barHover
        .style('top', (event.pageY - 10) + 'px')
        .style('left', (event.pageX + 10) + 'px')
        .attr('class', 'bar-hover ' + borderStyle)
        .text(type + ': ' + d[1] + ' supported');
    });

    selection.on('mouseout', function () {
      return barHover.style('visibility', 'hidden');
    });


  };
};
