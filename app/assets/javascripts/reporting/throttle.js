reporting.throttle = function throttle(func, timeout) {
  let next = null
  let timer = null

  return function theThrottle() {
    const context = this
    // eslint-disable-next-line prefer-rest-params
    const args = arguments

    function invoke() {
      if (next) next()
      timer = null
      next = null
    }

    if (!timer) {
      timer = setTimeout(invoke, timeout)
      func.apply(context, args)
    }

    next = () => {
      func.apply(context, args)
    }
  }
}
