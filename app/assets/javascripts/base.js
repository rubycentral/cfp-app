$(document).ready(function() {
  // Auto-dismiss alerts after 5 seconds (Bootstrap 5 style)
  setTimeout(function() {
    document.querySelectorAll('.alert:not(.alert-confirm):not(.scheduling-error)').forEach(function(el) {
      if (typeof bootstrap !== 'undefined' && bootstrap.Alert) {
        var alert = bootstrap.Alert.getOrCreateInstance(el);
        alert.close();
      }
    });
  }, 5000);

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

  // Tom Select for sortable multi-selects
  document.querySelectorAll(".selectize-sortable").forEach(function(el) {
    new TomSelect(el, {
      plugins: ["drag_drop"],
    });
  });

  // Tom Select for creatable multi-selects
  document.querySelectorAll(".selectize-create").forEach(function(el) {
    new TomSelect(el, {
      plugins: ["drag_drop"],
      persist: false,
      create: function (input) {
        return {
          value: input,
          text: input,
        };
      },
    });
  });
});

function cfpDataTable(selector, columnTypes, opt_options) {
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

  var $table = $(selector).dataTable(options);
  $table.columnFilter({
    sPlaceHolder: "head:before",
    aoColumns: columns
  });
  // Return the API instance for modern API access (e.g., fnSortNeutral)
  return $table.api();
}
