(function () {
  var validRangeLteq = function(value, element){
    var end_date = $("#report-form input[name='end']").attr('value');

    if(end_date === '') return true;
    return (Date.parse(value) <= Date.parse(end_date));
  };

  var validRangeGteq = function(value, element){
    var start_date = $("#report-form input[name='start']").attr('value');

    if(start_date === '') return true;
    return (Date.parse(value) >= Date.parse(start_date));
  };

  jQuery.validator.addMethod('validRangeLteq', validRangeLteq, null);
  jQuery.validator.addMethod('validRangeGteq', validRangeGteq, null);
}());
