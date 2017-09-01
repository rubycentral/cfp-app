$(function() {

  cfpDataTable('#program-sessions.datatable',
      [ 'text', 'text', 'text', 'text', 'text', 'text'],
      {
        'sDom': '<"top">Crt<"bottom"lp><"clear">'
      });
  cfpDataTable('#waitlisted-program-sessions.datatable',
      [ 'text', 'text', 'text', 'text', 'text', 'text', 'text'],
      {
        'sDom': '<"top">Crt<"bottom"lp><"clear">',
        'columnDefs': [{ 'orderable': false, targets: 5 }]
      });
});
