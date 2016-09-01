$(function() {

  cfpDataTable('#organizer-proposals-selection.datatable', [ 'text', 'text', 'text', 'text', 'text', 'text', 'text', 'text' ]);

  $('.by-track').hide();

  $('.track-select').change(function () {
    console.log('does this work?');
    if ($(this).val() == 'all') {
    }
    else {
      $('.by-track').show();
    }
  });
});
