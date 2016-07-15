$(function() {
  $(".time-slot").click(function () {
    $.ajax({
      url: $(this).data("time-slot-edit-path")
    });
  });
});