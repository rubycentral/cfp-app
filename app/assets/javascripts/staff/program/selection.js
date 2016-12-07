$(function() {

  cfpDataTable('#organizer-proposals-selection.datatable', [ 'text', 'text', 'text', 'text', 'text', 'text', 'text', 'text' ]);

  $(document).on('change', '.proposal-track-select', onProposalTrackChange);
  $(document).on('change', '.proposal-format-select', onProposalFormatChange);

  function onProposalTrackChange(ev) {
    $trackSelect = $(this);
    var trackId = $trackSelect.val();
    var url = $trackSelect.data('targetPath');

    $trackSelect.closest('td, span, div').load(url, { track_id: trackId }, function(response, status, xhr) {
      updateProposalSelect(response, 'track')
    });
  }

  function onProposalFormatChange(ev) {
    $formatSelect = $(this);
    var formatId = $formatSelect.val();
    var url = $formatSelect.data('targetPath');

    $formatSelect.closest('td, span, div').load(url, { session_format_id: formatId }, function(response, status, xhr) {
      updateProposalSelect(response, 'format')
    });
  }

  function updateProposalSelect(response, selectName) {
    var html = $.parseHTML(response);
    var opt = $('option:selected', html).text();

    if (selectName == 'track') {
      if (/General/i.test(opt)) {
        var opt = 'General'
      }
    }

    $('#' + selectName + '-name').html(opt);
    $('#edit-' + selectName + '-wrapper').hide();
    $('#current-' + selectName).show();
  }
});
