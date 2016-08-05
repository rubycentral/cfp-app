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

  // Manually show the popover for clicked-on element, and dismiss all
  // other popovers when new one displayed.
  $(document).on('click', '.popover-trigger', function(ev) {
    var selector = $(this).data('target');
    var toggle = $(selector);
    $.each($("[data-toggle~='popover']"), function(i, pop) {
      pop = $(pop);
      if (pop.is(toggle)) {
        pop.popover('toggle');
      } else {
        pop.popover('hide');
      }
    });
  });
});
