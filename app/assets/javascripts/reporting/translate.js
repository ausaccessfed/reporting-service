reporting.translate = function(x, y) {
  return function(selection) {
    selection.attr('transform', 'translate(' + x + ',' + y + ')');
  };
};
