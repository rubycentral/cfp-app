$(document).ready(function () {
  $('#event_closes_at, #event_opens_at, #event_start_date, #event_end_date').datetimepicker({
    controlType: 'select',
    dateFormat: 'M d, y at'
  });

  $('.dataTables_info').addClass('text-muted');
});
