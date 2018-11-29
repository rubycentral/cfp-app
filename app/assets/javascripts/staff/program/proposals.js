$(document).ready(function () {

  cfpDataTable('#organizer-proposals.datatable', ['number', 'number', 'number',
        'text', 'text', null, 'text', 'text', 'text', 'text', null],
    {
      stateSaveParams: function () {
        var rows = $('[data-proposal-id]');
        var uuids = [];
        rows.each(function (i, row) {
          uuids.push($(row).data('proposal-uuid'));
        });
        localStorage.proposal_uuid_table_order = JSON.stringify(uuids);
      },
      'sDom': '<"top"i>Crt<"bottom"lp><"clear">'
    });

  // Replace next proposal link with valid proposal path
  var next_link = $(".next-proposal");
  if (next_link.length > 0) {
    if (localStorage.proposal_uuid_table_order !== undefined) {
      var proposal_uuids = JSON.parse(localStorage.proposal_uuid_table_order);
      var current_index = proposal_uuids.indexOf(next_link.data("proposal-uuid"));
      if (current_index + 1 < proposal_uuids.length) {
        var next_uuid = proposal_uuids[current_index + 1];
        var href = next_link.attr("href");
        var new_href = href.replace("PLACEHOLDER", next_uuid);
        next_link.attr("href", new_href);
      } else {
        next_link.remove();
      }
    } else {
      next_link.remove();
    }
  }
});
