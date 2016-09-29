$(document).ready(function() {
  initTimeSlotsTable();
});

function initTimeSlotsTable() {
  cfpDataTable('#organizer-time-slots.datatable', [ 'number', 'text',
    'text', 'text', 'text', 'text', 'text' ],
    { "aaSorting": [ [0,'asc'], [1,'asc'] ] });
}

function initTimeSlotTimePickers() {
  $('#time_slot_start_time, #time_slot_end_time').timepicker({
      timeFormat: 'HH:mm'
  });
}

function setUpTimeSlotDialog($dialog) {
  initTimeSlotTimePickers();

  $(document).on('change', '.available-proposals', onSessionSelectChange);

  updateInfoFields($dialog.find('.available-proposals'));

  function updateInfoFields($select) {
    var $form = $select.closest('form');
    var $fields = $form.find('.supplemental-fields');
    var $info = $form.find('.selected-session-info');

    var data = $select.find(':selected').data();
    if (data) {
      $info.find('.title').html(data['title']);
      $info.find('.track').html(data['track']);
      $info.find('.speaker').html(data['speaker']);
      $info.find('.abstract').html(data['abstract']);
      $info.find('.confirmation-notes').html(data['confirmationNotes']);
    }

    if ($select.val() === '') {
      $fields.show();
      $info.hide();
    } else {
      $fields.hide();
      $info.show();
    }
  }

  function onSessionSelectChange(ev) {
    updateInfoFields($(this));
  }
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

function renderTimeSlots(html) { // currently unused
  $('#time_slots').html(html);
  initTimeSlotsTable();
}

function getTimeSlotsTable() {
  return $('#organizer-time-slots.datatable').dataTable();
}

function reloadTimeSlotsTable(rows) {
  var table = getTimeSlotsTable();
  table.fnClearTable();

  for (var i = 0; i < rows.length; ++i) {
    addTimeSlotRow(rows[i], table);
  }
}

function addTimeSlotRow(row_obj, opt_table) {
  var table;

  if (opt_table === undefined) {
    table = getTimeSlotsTable();
  } else {
    table = opt_table;
  }

  var index = table.fnAddData(row_obj.values);

  var row = $(table.fnGetNodes(index));
  row.attr('id', 'time_slot_' + row_obj.id);
}
