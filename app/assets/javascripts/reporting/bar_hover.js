reporting.barHover = function (barHover, type) {
  return function (selection) {
    selection.on('mouseover', function () {
      return barHover.style('visibility', 'visible');
    });

    selection.on('mousemove', function (d) {
      var dataIndex = {
        core: 1, optional: 2
      };

      var borderStyle = {
        core: 'border-vibrant',
        optional: 'border-primary'
      };

      return barHover
        .style('top', (event.pageY - 10) + 'px')
        .style('left', (event.pageX + 10) + 'px')
        .attr('class', 'bar-hover ' + borderStyle[type])
        .text(type + ': ' + d[dataIndex[type]] + ' supported');
    });

    selection.on('mouseout', function () {
      return barHover.style('visibility', 'hidden');
    });


  };
};
