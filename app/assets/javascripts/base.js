$(document).ready(function() {
  // Initialize Bootstrap 5 dropdowns with manual click handling
  // (Bootstrap's native data-bs-toggle doesn't work with Sprockets loading)
  if (typeof bootstrap !== 'undefined' && bootstrap.Dropdown) {
    document.querySelectorAll('.dropdown-toggle').forEach(function(el) {
      var dropdown = new bootstrap.Dropdown(el);
      el.addEventListener('click', function(e) {
        e.preventDefault();
        bootstrap.Dropdown.getInstance(el).toggle();
      });
    });
  }
});

function cfpDataTable(selector, columnTypes, opt_options) {
  var $el = $(selector);

  // Skip if already initialized (prevents Turbo cache issues)
  if ($.fn.DataTable.isDataTable($el)) {
    return $el.DataTable();
  }

  var columns = columnTypes.map(function(t) {
    if (t !== null) return { type: t };
  });

  var options = {
    "sPaginationType": "bootstrap",
    "bPaginate": false,
    "bStateSave": true,
    "sDom": '<"top">Crt<"bottom"ilp><"clear">'
  };

  $.extend(options, opt_options);

  var $table = $el.dataTable(options);
  $table.columnFilter({
    sPlaceHolder: "head:before",
    aoColumns: columns
  });
  // Return the API instance for modern API access (e.g., fnSortNeutral)
  return $table.api();
}
