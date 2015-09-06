reporting.throttle = function (func, timeout) {
  var next = null, timer = null;

  return function() {
    var context = this, args = arguments;

    var invoke = function() {
      if (next) next();
      timer = null;
      next = null;
    };

    if (!timer) {
      timer = setTimeout(invoke, timeout);
      func.apply(context, args);
      return;
    }

    next = function() { func.apply(context, args); };
  };
};
