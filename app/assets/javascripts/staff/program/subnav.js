$(function() {

  $(document).on('change', '.track-select', onTrackChange);
  updateVisibility();

  function updateVisibility() {
    if ($('#track-select').val() === 'all') {
      $('.by-track').hide();
    } else {
      $('.by-track').show();
    }
  }

  function onTrackChange() {
    var trackId = $('#track-select').val().trim();
    var eventSlug = $(this).data('event');

    $.ajax({
      url: '/events/' + eventSlug + '/staff/program/proposals/session_counts',
      dataType: 'json',
      data: { track_id: trackId },
      type: 'GET',
      success: onSuccess
    });
  }

  function onSuccess(data) {
    $('.by-track.all-accepted').find('.badge').text(data.all_accepted_proposals);
    $('.by-track.all-waitlisted').find('.badge').text(data.all_waitlisted_proposals);

    updateVisibility();
  }

  // On-demand body padding for fixed subnav pages
  if($('[class*="subnav"]').length > 0) {
    var padTop = $('[class*="subnav"]').height();
    $('body').css('padding-top', '+=' + padTop + 'px');
  }
});
