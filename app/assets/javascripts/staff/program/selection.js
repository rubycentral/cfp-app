$(function() {

  cfpDataTable('#organizer-proposals-selection.datatable', [ 'text', 'text', 'text', 'text', 'text', 'text', 'text', 'text' ]);

  $(document).on('change', '.proposal-track-select', onProposalTrackChange);

  function onProposalTrackChange(ev) {
    $trackSelect = $(this);
    var trackId = $trackSelect.val();
    var url = $trackSelect.data('targetPath');

    $trackSelect.closest('td, span, div').load(url, { track_id: trackId });
  }
});
