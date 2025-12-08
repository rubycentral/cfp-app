export default function cfpDataTable(selector, columnTypes, options = {}) {
  const $el = $(selector)

  // Skip if already initialized (prevents Turbo cache issues)
  if ($.fn.DataTable.isDataTable($el)) {
    return $el.DataTable()
  }

  const columns = columnTypes.map(t => {
    if (t !== null) return {type: t}
  })

  const defaultOptions = {
    sPaginationType: 'bootstrap',
    bPaginate: false,
    bStateSave: true,
    sDom: '<"top">Crt<"bottom"ilp><"clear">'
  }

  const $table = $el.dataTable({...defaultOptions, ...options})
  $table.columnFilter({
    sPlaceHolder: 'head:before',
    aoColumns: columns
  })

  // Return the API instance for modern API access
  return $table.api()
}
