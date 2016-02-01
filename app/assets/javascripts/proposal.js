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
    if (maxlength <= current_length) {
      alert("Character limit of " + maxlength + " has been exceeded");
    }
  });

  $('#tags_form').submit(function() {
    var valuesToSubmit = $(this).serialize();
    $.ajax({
      type: "POST",
      url: $(this).attr('action'), //sumbits it to the given url of the form
      data: valuesToSubmit,
      dataType: "JSON"
    }).success(function(json){
      console.log("success", json);
    });
    return false; // prevents normal behaviour
  });
});
