(function($, window) {
  if (typeof(window.Schedule) === 'undefined') {
    window.Schedule = {};
  }
  if (typeof(window.Schedule.TimeSlots) !== 'undefined') {
    return window.Schedule.TimeSlots;
  }

  function initDialog($dialog) {
    $dialog.find('.available-proposals').change(onSessionSelectChange);
    $dialog.find('.start-time, .end-time').change(onTimeChange);

    updateInfoFields($dialog);
  }

  function updateInfoFields($container) {
    var $selected = $container.find('.available-proposals :selected');
    var $fields = $container.find('.supplemental-fields');
    var $info = $container.find('.selected-session-info');
    var $endTime = $container.find('.end-time');
    var $duration = $container.find('.duration');

    var data = $selected.data();
    $info.find('.title').html(data['title']);
    $info.find('.track').html(data['track']);
    $info.find('.speaker').html(data['speaker']);
    $info.find('.abstract').html(data['abstract']);
    $info.find('.duration').html(data['duration'] + " minutes");

    if ($selected.val() === '') {
      $fields.removeClass('hidden');
      $info.addClass('hidden');
    } else {
      $fields.addClass('hidden');
      $info.removeClass('hidden');
    }
  }

  function updateLength($container) {
    var $length = $('.length-label .length');
    var start = document.getElementById('time_slot_start_time').value;
    var end = document.getElementById('time_slot_end_time').value;

    if (start && end) {
      var s = moment(start, 'HH:mm');
      var e = moment(end, 'HH:mm');
      var diff = e.diff(s, 'minutes');
      $length.text(diff + ' minutes');
    }
  }

  function onSessionSelectChange(ev) {
    var $form = $(this).closest('form');
    updateInfoFields($form);
  }

  function onTimeChange(ev) {
    var $form = $(this).closest('form');
    updateLength($form)
  }

  window.Schedule.TimeSlots = {
    initDialog: initDialog
  };

})(jQuery, window);
