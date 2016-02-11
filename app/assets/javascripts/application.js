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

    $('#delete-confirm').on('show', function() {
    var $submit = $(this).find('.btn-danger'),
        href = $submit.attr('href');
      $submit.attr('href', href.replace('pony', $(this).data('id')));
    });

    $('.delete-confirm').click(function(e) {
      e.preventDefault();
      $('#delete-confirm').data('id', $(this).data('id')).modal('show');
    });

    $('[data-toggle="tooltip"]').tooltip();
  }($));
});
