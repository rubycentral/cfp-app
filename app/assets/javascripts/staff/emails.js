$(document).ready(function() {

  $('.template-exit-preview-btn').hide();
  $('.template-preview').hide();
  $('.template-edit').hide();
  $('.template-save-btn, .template-remove-btn, .template-cancel-btn').hide();

  $('.template-preview-btn').click(function(e) {
    e.preventDefault();
    $parent = $(this).parents('.template-section');
    $parent.find('.template-short').hide();
    $parent.find('.template-edit').hide();
    $parent.find('.template-preview').show();
    $parent.find('.template-preview-btn').hide();
    $parent.find('.template-exit-preview-btn').show();
  });

  $('.template-exit-preview-btn').click(function(e) {;
    e.preventDefault();
    $parent = $(this).parents('.template-section');
    $parent.find('.template-preview').hide();
    $parent.find('.template-edit').hide();
    $parent.find('.template-short').show();
    $parent.find('.template-exit-preview-btn').hide();
    $parent.find('.template-preview-btn').show();
  });

  $('.template-edit-btn').click(function(e) {;
    e.preventDefault();
    $parent = $(this).parents('.template-section');
    $parent.find('.template-preview').hide();
    $parent.find('.template-short').hide();
    $parent.find('.template-edit').show();
    $parent.find('.template-edit-btn, .template-preview-btn').hide();
    $parent.find('.template-save-btn, .template-remove-btn, .template-cancel-btn').show();
  });
});
