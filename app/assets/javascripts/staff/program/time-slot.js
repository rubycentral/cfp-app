(function($, window) {
  if (typeof(window.Schedule) === 'undefined') {
    window.Schedule = {};
  }
  if (typeof(window.Schedule.TimeSlots) !== 'undefined') {
    return window.Schedule.TimeSlots;
  }

  function initDialog($dialog) {
    initTimePickers();

    $dialog.find('.available-proposals').change(onSessionSelectChange);
    $dialog.find('.start-time').change(onTimeChange);

    updateInfoFields($dialog);
  }

  function initTimePickers() {
    $('#time_slot_start_time, #time_slot_end_time').timepicker({
      timeFormat: 'HH:mm',
      stepMinute: 5
    });
  }

  function updateInfoFields($container) {
    var $selected = $container.find('.available-proposals :selected');
    var $fields = $container.find('.supplemental-fields');
    var $info = $container.find('.selected-session-info');
    var $endTime = $container.find('.end-time');

    var data = $selected.data();
    $info.find('.title').html(data['title']);
    $info.find('.track').html(data['track']);
    $info.find('.speaker').html(data['speaker']);
    $info.find('.abstract').html(data['abstract']);

    if ($selected.val() === '') {
      $fields.removeClass('hidden');
      $info.addClass('hidden');
      $endTime.prop('readonly', false);
    } else {
      $fields.addClass('hidden');
      $info.removeClass('hidden');
      $endTime.prop('readonly', true);
    }
  }

  function updateEndTime($container) {
    var $selected = $container.find('.available-proposals :selected');
    var $startTime = $container.find('.start-time');
    var $endTime = $container.find('.end-time');

    var sid = $selected.val();
    var start = $startTime.val();
    if (sid.length > 0 && start.length > 0) {
      var m = moment(start, 'HH:mm').add($selected.data('duration'), 'minutes');
      $endTime.val(m.format('HH:mm'));
    }
  }

  function onSessionSelectChange(ev) {
    var $form = $(this).closest('form');
    updateInfoFields($form);
    updateEndTime($form);
  }

  function onTimeChange(ev) {
    var $form = $(this).closest('form');
    updateEndTime($form);
  }



  function initTable() {
    cfpDataTable('#organizer-time-slots.datatable', [ 'number', 'text',
          'text', 'text', 'text', 'text', 'text' ],
        { "aaSorting": [ [0,'asc'], [1,'asc'] ] });
  }

  function getDataTable() {
    return $('#organizer-time-slots.datatable').dataTable();
  }

  function reloadTable(rows) {
    var table = getDataTable();
    table.fnClearTable();

    for (var i = 0; i < rows.length; ++i) {
      addRow(rows[i], table);
    }
  }

  function addRow(row_obj, opt_table) {
    var table;

    if (opt_table === undefined) {
      table = getDataTable();
    } else {
      table = opt_table;
    }

    var index = table.fnAddData(row_obj.values);

    var row = $(table.fnGetNodes(index));
    row.attr('id', 'time_slot_' + row_obj.id);
  }


  window.Schedule.TimeSlots = {
    initTable: initTable,
    reloadTable: reloadTable,
    addRow: addRow,

    initDialog: initDialog
  };

})(jQuery, window);

$(document).ready(function() {
  window.Schedule.TimeSlots.initTable();
});
