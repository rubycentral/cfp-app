$(document).ready(function() {
  initSessionsTable();
  initSessionTimePickers();
});

function initSessionsTable() {
  cfpDataTable('#organizer-sessions.datatable', [ 'number', 'text',
    'text', 'text', 'text', 'text', 'text' ],
    { "aaSorting": [ [0,'asc'], [1,'asc'] ] });
}

function initSessionTimePickers() {
  $('#session_start_time, #session_end_time').timepicker({
      timeFormat: 'HH:mm'
  });
}

function setUpSessionDialog(dialog) {
  dialog.find('#cancel').click(function(e) {
    dialog.empty();
    dialog.modal('hide');
    return false;
  });

  initSessionTimePickers();

  var proposalSelect = $('#session_proposal_id');
  var fields = $('#session_title, #session_presenter, #session_description');

  var toggleFields = function() {
    if (proposalSelect.val() === '') {
      fields.prop('disabled', false);
    } else {
      fields.prop('disabled', true);
    }
  };

  proposalSelect.change(function() {
    toggleFields();
    var notes = $(this).find(':selected').data('confirmation-notes');
    $('#confirmation-notes').text(notes);
  });

  toggleFields();
}

function clearFields(fields, opt_parent) {
  var parentNode = opt_parent === undefined ? null : $(opt_parent);

  var node;
  for(var i = 0; i < fields.length; ++i) {
    if (parentNode !== null) {
      node = parentNode.find(fields[i]);
    } else {
      node = $(fields[i]);
    }

    node.val('');
  }
}

function renderSessions(html) {
  $('#sessions').html(html);
  initSessionsTable();
}

function getSessionsTable() {
  return $('#organizer-sessions.datatable').dataTable();
}

function reloadSessionsTable(rows) {
  var table = getSessionsTable();
  table.fnClearTable();

  for (var i = 0; i < rows.length; ++i) {
    addSessionRow(rows[i], table);
  }
}

function addSessionRow(row_obj, opt_table) {
  var table;

  if (opt_table === undefined) {
    table = getSessionsTable();
  } else {
    table = opt_table;
  }

  var index = table.fnAddData(row_obj.values);

  var row = $(table.fnGetNodes(index));
  row.attr('id', 'session_' + row_obj.id);
}
