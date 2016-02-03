(function () {
  var validRangeLteq = function(value, element){
    var end_date = $("#report-form input[name='end']").attr('value');
    return (Date.parse(value) <= Date.parse(end_date)) === (end_date !== '');
  };

  var validRangeGteq = function(value, element){
    var start_date = $("#report-form input[name='start']").attr('value');
    return (Date.parse(value) >= Date.parse(start_date)) === (start_date !== '');
  };

  jQuery.validator.addMethod('validRangeLteq', validRangeLteq, null);
  jQuery.validator.addMethod('validRangeGteq', validRangeGteq, null);
}());
