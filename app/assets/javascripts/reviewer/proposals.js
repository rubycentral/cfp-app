$(document).ready(function() {

  $.datepicker.regional[""].dateFormat = 'yy-mm-dd ';
  $.datepicker.setDefaults($.datepicker.regional['']);

  var oTable = cfpDataTable('#reviewer-proposals.datatable', [ 'number', null,
    'number', 'text', 'text', 'text', 'number', 'text', 'text', null ]);

  $("#sort_reset").click(function(){
    oTable.fnSortNeutral();
  });

  $('table input').addClass('form-control');

  $('.multiselect').multiselect({
    buttonClass: 'btn btn-default',
    buttonText: function(options, select) {
      if (options.length == 0) {
        return 'None selected <b class="caret"></b>';
      } else {
        var tagClass = 'label ';
        if ($(select).hasClass('review-tags')) {
            tagClass += 'label-success';
        } else {
            tagClass += 'label-primary';
        }
        var selected = '';
        options.each(function() {
          selected += '<span class="' + tagClass + '">' + $(this).html() + '</span> ';
        });
        return selected + '<b class="caret"></b>';
      }
    }
  });

});
