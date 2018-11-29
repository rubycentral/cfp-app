$(document).ready(function() {
  $('.template-exit-preview-btn, .template-preview, .template-edit, .email-markup-help').hide();
  $('.template-save-btn, .template-remove-btn, .template-cancel-btn').hide();

  $('.template-preview-btn').click(function(e) {
    e.preventDefault();
    $parent = $(this).parents('.template-section');
    $parent.find('.template-short, .template-edit').hide();
    $parent.find('.template-preview-btn').hide();
    $parent.find('.template-preview').show();
    $parent.find('.template-exit-preview-btn').show();
    $('.email-markup-help').show();
  });

  $('.template-exit-preview-btn').click(function(e) {
    e.preventDefault();
    $parent = $(this).parents('.template-section');
    $('.email-markup-help').hide();
    $parent.find('.template-preview, .template-edit').hide();
    $parent.find('.template-exit-preview-btn').hide();
    $parent.find('.template-short').show();
    $parent.find('.template-preview-btn').show();
  });

  $('.template-edit-btn').click(function(e) {
    e.preventDefault();
    $('.template-section').hide();
    $parent = $(this).parents('.template-section');
    $parent.show();

    $parent.find('.template-preview, .template-short').hide();
    $parent.find('.template-exit-preview-btn, .template-edit-btn, .template-preview-btn, .template-test-btn').hide();
    $('.email-markup-help').show();
    $parent.find('.template-edit').show();
    $parent.find('.template-save-btn, .template-remove-btn, .template-cancel-btn').show();
  });

  $('.modal-content').keypress(function(e){
    if(e.which == 13) {
      $(this).find('form').submit();
      e.preventDefault();
    }
  });
});
