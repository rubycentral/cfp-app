var registerNotificationChannel = function() {
  App.notifications = App.cable.subscriptions.create("NotificationsChannel", {
    connected: function() {
      // Called when the subscription is ready for use on the server
      console.log("Connected to notifications channel");
    },

    disconnected: function() {
      // Called when the subscription has been terminated by the server
      console.log("Disconnected from notifications channel");
    },

    received: function(data) {
      console.log("Received data:", data);
      $('#notifications').text(data.message);
      if (data.complete === "1") {
        $('tr[data-state=' + data.state + ']').remove();
      }
    }
  });
};

$(document).ready(function () {
  var oTable = cfpDataTable('#reviewer-proposals.datatable', ['number', null,
      'number', 'text', 'text', 'text', 'text', 'text', 'number', 'text', 'text'],
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

  $("#sort_reset").click(function () {
    // Clear sort order and restore original row order
    var settings = oTable.settings()[0];
    settings.aaSorting = [];
    settings.aiDisplay.sort(function(x, y) { return x - y; });
    settings.aiDisplayMaster.sort(function(x, y) { return x - y; });
    oTable.draw();
  });

  $('table input').addClass('form-control');
});

