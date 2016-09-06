$(function() {

  cfpDataTable('#organizer-proposals-selection.datatable', [ 'text', 'text', 'text', 'text', 'text', 'text', 'text', 'text' ]);

  $('.by-track').hide();

  $('.track-select').change(function () {
    var successFn = function (data) {
      $('.by-track.soft-accepted').find('.badge').text(data.soft_accepted_count);
      $('.by-track.soft-waitlisted').find('.badge').text(data.soft_waitlisted_count);
      $('.by-track').show();
    };

    var trackId = $('#track-select').val();
    var eventSlug = $(this).data('event');

    if (trackId === 'all') {
      $('.by-track').hide();
    } else {
      $.ajax({
        url: '/events/' + eventSlug + '/staff/program/proposals/program_counts',
        dataType: 'json',
        data: { trackId: trackId },
        type: 'GET',
        success: successFn
      });
    }
  });

  $(document).on('change', '.proposal-track-select', function () {
    $trackSelect = $(this);
    var trackId = $trackSelect.val();
    var url = $trackSelect.data('targetPath');

    $trackSelect.closest('td').load(url, { track_id: trackId });
    // {
    //   url: url,
    //   dataType: 'json',
    //   data: { track_id: trackId },
    //   type: 'POST'
    // });
  });
});
