$(function() {

  cfpDataTable('#program-sessions.datatable',
    [ 'text', 'text', 'text', null, 'text', 'text', 'text'],
    {
      'sDom': '<"top">Crt<"bottom"lp><"clear">'
    }
  );
});

$(document).ready(function () {
    if ($("#program-sessions.datatable").length > 0) {
        filterProgramSessionsBy("program")

        $(".quick-filter-tabs .tab").on('click', function(e) {
            filterProgramSessionsBy(e.currentTarget.id)
        })
    }
})

function filterProgramSessionsBy(type) {
    // move tab indicator
    var $tab = $("#" + type + ".tab")
    var position = $tab.position().left
    var width = $tab.width()
    $(".quick-filter-tabs .indicator").animate({
        left: position,
        width: width,
    }, 300)

    // filter the list
    var $dataTable = $("#program-sessions.datatable").DataTable()
    $dataTable.column(8).search(type).draw()
}
