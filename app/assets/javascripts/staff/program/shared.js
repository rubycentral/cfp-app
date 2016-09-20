$(function() {

  var btnCopy = $('#copy-filtered-speaker-emails');
  client = new ZeroClipboard(btnCopy);
  client.on('ready', function() {
    console.log('zero clipboard is ready')
  });
  client.on('beforecopy', function() {
    var ids = [];
    $('.datatable tbody tr').each(function(i, row) {
      ids.push(row.dataset.sessionId);
    });

    $.ajax({
      url: btnCopy.data('url'),
      data: { session_ids: ids },
      async: false,
      success: function(obj) {
        client.setText(obj.emails.join(','));
      }
    });
  });

});
