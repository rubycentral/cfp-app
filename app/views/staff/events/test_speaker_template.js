(function($) {
  var $dialog = $('#test-template-<%= @type_key %>-dialog');
  $dialog.modal('hide');

  $('#flash').html('<%=j show_flash %>');

})(jQuery);