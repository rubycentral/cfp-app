$(function() {

  cfpDataTable('#organizer-proposals-selection.datatable', [ 'text', 'text', 'text', 'text', 'text', 'text', 'text', 'text' ]);

  $('.by-track').hide();

  $('.track-select').change(function () {
    var successFn = function (data) {
      $('.by-track.all-accepted').find('.badge').text(data.all_accepted_count);
      $('.by-track.all-waitlisted').find('.badge').text(data.all_waitlisted_count);
      $('.by-track').show();
    };

    var trackId = $('#track-select').val();
    var eventSlug = $(this).data('event');

    if (trackId === 'all') {
      $('.by-track').hide();
    } else {
      $.ajax({
        url: '/events/' + eventSlug + '/staff/program/proposals/session_counts',
        dataType: 'json',
        data: { track_id: trackId },
        type: 'GET',
        success: successFn
      });
    }
  });

  $(document).on('change', '.proposal-track-select', function () {
    $trackSelect = $(this);
    var trackId = $trackSelect.val();
    var url = $trackSelect.data('targetPath');

    $trackSelect.closest('td, span, div').load(url, { track_id: trackId });
    // {
    //   url: url,
    //   dataType: 'json',
    //   data: { track_id: trackId },
    //   type: 'POST'
    // });
  });
});
