$(function() {

  cfpDataTable('#organizer-proposals-selection.datatable', [ 'text', 'text', 'text', null, 'text', 'text', 'text', 'text' ]);

  setupPopovers()

  $(document).on('change', '.proposal-track-select', onProposalTrackChange);
  $(document).on('change', '.proposal-format-select', onProposalFormatChange);

  function onProposalTrackChange(ev) {
    removePopover('track')
    $trackSelect = $(this);
    var trackId = $trackSelect.val();
    var url = $trackSelect.data('targetPath');

    $trackSelect.closest('td, span, div').load(url, { track_id: trackId }, function(response, status, xhr) {
      updateProposalSelect(response, 'track', trackId)
    });
  }

  function onProposalFormatChange(ev) {
    removePopover('format')
    $formatSelect = $(this);
    var formatId = $formatSelect.val();

    var url = $formatSelect.data('targetPath');

    $formatSelect.closest('td, span, div').load(url, { session_format_id: formatId }, function(response, status, xhr) {
      updateProposalSelect(response, 'format', formatId)
    });
  }

  function updateProposalSelect(response, selectName, newId) {
    var html = $.parseHTML(response);
    var opt = $("option[value='" + newId + "']", html).text()
    $('#' + selectName + '-name').html(opt);
    $('#edit-' + selectName + '-wrapper')
      .hide()
      .find(".control-label").last().remove();
    $('#current-' + selectName).show();
    setupPopovers()
  }

  function setupPopovers() {
    $('[data-toggle="popover"]').popover({
      container: 'body',
    });
  }

  function removePopover(selectName) {
    var targetId = $('#edit-' + selectName + '-wrapper').find('select').attr('aria-describedby')
    $('#' + targetId).remove()
  }
});
