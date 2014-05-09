$(document).ready(function() {
  $('#event_closes_at, #event_opens_at, #event_start_date, #event_end_date').datetimepicker({
      controlType: 'select',
      dateFormat: 'yy-mm-dd',
      timeFormat: 'HH:mm z',
  });

  $('.dataTables_info').addClass('text-muted');
});
