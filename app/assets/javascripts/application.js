//= require 'aaf-lipstick'
//= require 'd3'
//= require 'reporting'
//= require 'render_report'
//= require jq_validations.js

$(document).ready(function() {
  (function($) {
    $('#filter').keyup(function() {
      var text = new RegExp($(this).val(), 'i');

      $('.filtertable tr').hide();
      $('.filtertable tr').filter(function() {
          return text.test($(this).text());
      }).show();
    })
  }($));
});
