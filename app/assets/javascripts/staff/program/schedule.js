$(function() {
  // ruler properties
  const dayStart = 60*8;  // minutes
  const dayEnd = 60*20;
  const step = 60;
  const verticalScale = 1.0;

  initGrid();
  $(document).on('click', '.schedule-grid .time-slot', onTimeSlotClick);

  function initGrid(day) {
    var gridSelector = '.schedule-grid';
    if (Number.isInteger(day)) {
      gridSelector = '#schedule_day_' + day + gridSelector;
    }
    $(gridSelector + ' .time-slot').each(function(i, slot) {
      var $slot = $(slot);
      $slot.css({
        height: $slot.data('duration') + 'px',
        top: ($slot.data('starts') - dayStart) + 'px'
      })
    });

    $(gridSelector + ' .ruler').each(function(i, ruler) {
      initRuler($(ruler));
    });
  }

  function initRuler($ruler) {
    var m = moment().startOf('day').minutes(dayStart-step);
    for (var i=dayStart; i<=dayEnd; i+=step) {
      $ruler.append('<li>'+ m.minutes(step).format('hh:mma') +'</li>')
    }
  }

  function onTimeSlotClick(ev) {
    $.ajax({
      url: $(this).data('editPath'),
      success: function(data) {
        $(ev.target).closest('.schedule-grid');
      }
    });
  }
});