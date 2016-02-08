reporting.barHover = function (barHover, sizing, barDataIndex, type) {
  var borderStyle = {
    core: 'border-vibrant',
    optional: 'border-primary'
  };

  return function (selection) {
    selection.on('mouseover', function () {
      return barHover.style('visibility', 'visible');
    });

    selection.on('mousemove', function (data) {
      return barHover
        .style('top', (event.pageY + sizing.hoverPointerOffset.y) + 'px')
        .style('left', (event.pageX + sizing.hoverPointerOffset.x) + 'px')
        .attr('class', 'bar-hover ' + borderStyle[type])
        .text(type + ': ' + data[barDataIndex[type]] + ' supported');
    });

    selection.on('mouseout', function () {
      return barHover.style('visibility', 'hidden');
    });
  };
};
