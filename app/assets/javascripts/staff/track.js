$(document).ready(function () {
    if ($('select#track-select').length) {
        filterTableByTrack()
        $(document).on('change', '.track-select', filterTableByTrack)
    }

    function filterTableByTrack() {
        var $dataTable = $('table.datatable').DataTable()
        var track = $('select#track-select option:selected').text()
        if (track === 'All') {
            $dataTable.search('').columns().search('').draw()
        } else {
            $dataTable.search('').columns().search('').draw()
            var $trackColumn = $dataTable.column(':contains(Track)')
            $trackColumn.search(track).draw()
        }
    }
})
