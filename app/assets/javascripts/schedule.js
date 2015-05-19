$(function() {
  $(".session-slot").click(function () {
    console.log("session clicked");
    $.ajax({
      url: $(this).data("session-edit-path"),
    //  success: function(data) {
        //eval(data);
    //  }
    });
  });
});