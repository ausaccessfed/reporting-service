reporting.rotate = function(angle, x, y) {
  return function(selection) {
    selection.attr('transform', 'translate(' + x + ',' + y + ') '
                                 + 'rotate(' + angle + ')');
  };
};
