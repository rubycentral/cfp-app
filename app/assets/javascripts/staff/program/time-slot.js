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
    $dialog.find('.start-time, .end-time').change(onTimeChange);

    updateInfoFields($dialog);
  }

  function initTimePickers() {
    $('#time_slot_start_time').timepicker({
      controlType: 'select',
      timeFormat: 'h:mm tt',
      stepMinute: 5,
      onSelect: function(time) {
        $('#time_slot_end_time').timepicker('destroy');
        initTimePickers();
      }
    });
    $('#time_slot_end_time').timepicker({
      controlType: 'select',
      timeFormat: 'h:mm tt',
      stepMinute: 5,
      onSelect: function(time) {
        $('#time_slot_start_time').timepicker('destroy');
        initTimePickers();
      }
    });
  }

  function updateInfoFields($container) {
    var $selected = $container.find('.available-proposals :selected');
    var $fields = $container.find('.supplemental-fields');
    var $info = $container.find('.selected-session-info');
    var $endTime = $container.find('.end-time');
    var $duration = $container.find('.duration');

    var data = $selected.data();
    $info.find('.title').html(data['title']);
    $info.find('.track').html(data['track']);
    $info.find('.speaker').html(data['speaker']);
    $info.find('.abstract').html(data['abstract']);
    $info.find('.duration').html(data['duration'] + " minutes");

    if ($selected.val() === '') {
      $fields.removeClass('hidden');
      $info.addClass('hidden');
    } else {
      $fields.addClass('hidden');
      $info.removeClass('hidden');
    }
  }

  function updateLength($container) {
    var $length = $('.length-label .length');
    var start = document.getElementById('time_slot_start_time').value;
    var end = document.getElementById('time_slot_end_time').value;

    if (start && end) {
      var s = moment(start, 'h:mm a');
      var e = moment(end, 'h:mm a');
      var diff = e.diff(s, 'minutes');
      $length.text(diff + ' minutes');
    }
  }

  function onSessionSelectChange(ev) {
    var $form = $(this).closest('form');
    updateInfoFields($form);
  }

  function onTimeChange(ev) {
    var $form = $(this).closest('form');
    updateLength($form)
  }



  function initTable() {
    cfpDataTable('#organizer-time-slots.datatable', [ 'number', 'date',
      'date', 'text', 'text', 'text', 'text'], { "aaSorting": [[0, 'asc'], [1, 'asc']] });
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
    
    table.api().row.add($(row_obj)).draw()
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
