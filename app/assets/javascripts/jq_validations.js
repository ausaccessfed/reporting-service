(function () {
  var validRangeLteq = function(value, element){
    var end_date = $('#report-form #end').val();
    return (Date.parse(value)) <= (Date.parse(end_date));
  };

  var validRangeGteq = function(value, element){
    var start_date = $('#report-form #start').val();
    return (Date.parse(value)) >= (Date.parse(start_date));
  };

  jQuery.validator.addMethod('validRangeLteq', validRangeLteq, null);
  jQuery.validator.addMethod('validRangeGteq', validRangeGteq, null);
}());
