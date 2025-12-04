$(document).ready(function() {
  setTimeout(function() {
    $(".alert").not('.alert-confirm, .scheduling-error').alert('close');
  }, 5000);

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
