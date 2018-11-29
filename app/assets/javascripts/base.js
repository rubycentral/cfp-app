$(document).ready(function() {
  $("#gravatar-alert").tooltip();
  $('body').tooltip({selector: "[data-toggle~='tooltip']", html: true});

  setTimeout(function() {
    $(".alert").not('.alert-confirm').alert('close');
  }, 5000);
});

// Datatable extension for reseting sort order
$.fn.dataTableExt.oApi.fnSortNeutral = function ( oSettings ) {
    oSettings.aaSorting = [];
    oSettings.aiDisplay.sort( function (x,y) {
        return x-y;
    } );
    oSettings.aiDisplayMaster.sort( function (x,y) {
        return x-y;
    } );
    oSettings.oApi._fnReDraw( oSettings );
};

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

  return $(selector).dataTable(options).columnFilter({
    sPlaceHolder: "head:before",
    aoColumns: columns
  });
}
