$(function() {
  var preview = $('#proposal-preview');
  if (preview.length > 0) {
    var url = preview.data('remote-url');
    $('.watched').blur(function() {
      $.ajax({
        data: {
          id: this.id,
          text: $(this).val()
        },
        url: url
      });
    });
  }

  $('.js-maxlength-alert').keyup(function() {
    var maxlength = $(this).attr('maxlength');
    var current_length = $(this).val().length;
    if (current_length > maxlength) {
      alert("Character limit of " + maxlength + " has been exceeded");
    }
  });

  $('.speaker-invite-button').click(function() {
    $('.speaker-invite-form').toggle();
  });

  $('#edit-tags-icon').click(function() {
    $('.proposal-reviewer-tags, #edit-tags-icon').toggle();
    $('.review-tags-form-wrapper').slideToggle();
  });

  $('#cancel-tags-editing').click(function() {
    $('.review-tags-form-wrapper').toggle();
    $('.proposal-reviewer-tags, #edit-tags-icon').toggle();
  });

  if($('#autocomplete-options').length > 0) {
    var html = $('#autocomplete-options').html();
    var data = JSON.parse(html);
    var items = data.map(function(x) { return { item: x }; });

    $('#proposal_review_tags').selectize({
      delimiter: ',',
      persist: false,
      plugins: ['remove_button'],
      options: items,
      valueField: 'item',
      labelField: 'item',
      searchField: 'item',
      create: function(input) {
        return {
            value: input,
            text: input,
            item: input
        }
      }
    });
  }
});
