const jqValidations = () => {
  const validRangeLteq = (value, _element) => {
    const endDate = $("#report-form input[name='end']").attr('value')

    if (endDate === '') return true
    return Date.parse(value) <= Date.parse(endDate)
  }

  const validRangeGteq = (value, _element) => {
    const startDate = $("#report-form input[name='start']").attr('value')

    if (startDate === '') return true
    return Date.parse(value) >= Date.parse(startDate)
  }

  jQuery.validator.addMethod('validRangeLteq', validRangeLteq, null)
  jQuery.validator.addMethod('validRangeGteq', validRangeGteq, null)
}

jqValidations()
