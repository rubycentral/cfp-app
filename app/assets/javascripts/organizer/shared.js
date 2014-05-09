$(function() {

  var btnCopy = $('#copy-filtered-speaker-emails');
  client = new ZeroClipboard(btnCopy);
  client.on('dataRequested', function() {
    var ids = [];
    $('.datatable tbody tr').each(function(i, row) {
      ids.push(row.dataset.proposalId);
    });

    $.ajax({
      url: btnCopy.data('url'),
      data: { proposal_ids: ids },
      async: false,
      success: function(obj) {
        client.setText(obj.emails);
      }
    });
  });

});
