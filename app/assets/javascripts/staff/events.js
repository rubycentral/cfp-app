$(document).ready(function () {
  $('.status-button').click(function() {
    $('.status-dropdown').show();
    $('.btn-nav').hide();
  });

  $('.cancel-status-change').click(function() {
    $('.status-dropdown').hide();
    $('.btn-nav').show();
  });

  $('.modal').on('shown.bs.modal', function() {
    $(this).find('[autofocus]').focus();
  });
});
