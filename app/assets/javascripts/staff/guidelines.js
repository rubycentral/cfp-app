$(document).ready(function() {

  $('.guidelines-form').hide();

  $('.edit-guidelines-btn').click(function() {
    $('.guidelines-form').show();
    $('.guidelines-preview').hide();
    $('.edit-guidelines-btn').hide();
  });

});
