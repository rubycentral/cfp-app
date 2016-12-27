(function($, window) {
  if (typeof(window.Schedule) === 'undefined') {
    window.Schedule = {};
  }
  if (typeof(window.Schedule.Grid) !== 'undefined') {
    return window.Schedule.Grid;
  }

  // Grid properties
  const dayStart = 60*9;  // minutes
  const dayEnd = 60*19;
  const step = 60;
  const verticalScale = 2.5;

  var trackCssClasses = [];
  var trackColors = [];

  function init() {
    var $grids = $('.schedule-grid');
    if ($grids.length == 0) {
      return;
    }
    initTrackColors();
    addGridLineStyle();
    initGrid($grids);
  }

  function initGrid($grid) {
    $grid.find('.time-slot').each(function(i, slot) {
      initTimeSlot($(slot));
    });
    $grid.find('.ruler').each(function(i, ruler) {
      initRuler($(ruler));
    });
  }

  function initGridDay(day) {
    initGrid($('#schedule_day_' + day));
  }

  function initTimeSlot($slot) {
    $slot.css({
      height: ($slot.data('duration') * verticalScale) + 'px',
      top: (($slot.data('starts') - dayStart) * verticalScale) + 'px'
    });

    var trackCss = $slot.data('trackCss');
    var i = trackCssClasses.indexOf(trackCss);
    if (i >= 0) {
      $slot.find('.track').css({
        color: '#FFF',
        backgroundColor: '#' + trackColors[i]
      });
    }
    if (!$slot.hasClass('preview')) {
      $slot.click(onTimeSlotClick);
    }
  }

  function initRuler($ruler) {
    var m = moment().startOf('day').minutes(dayStart-step);
    for (var i=dayStart; i<=dayEnd; i+=step) {
      $ruler.append('<li>'+ m.minutes(step).format('hh:mma') +'</li>');
    }
  }

  function initTrackColors() {
    trackCssClasses = $('#schedule').data('tracks-css');
    trackColors = palette('tol-rainbow', trackCssClasses.length);
  }

  function addGridLineStyle() {
    // The ruler's ticks are extended by changing their width dynamically.
    var $columns = $('.schedule-grid:first').find('.room-column');
    var lineWidth = $columns.length * $columns.width() + 10;
    $('<style>.schedule-grid .ruler li:after { width: '+lineWidth+'px; }</style>').appendTo('head');
  }

  function initBulkCreateDialog($dialog) {
    var $format = $dialog.find('select.session-format');
    var $duration = $dialog.find('.time-slot-duration');

    $format.change(function(ev) {
      $duration.val($format.val());
    });
    $duration.keyup(function(ev) {
      if ($duration.is(':focus')) {
        $format.val('');
      }
    });
  }

  function onTimeSlotClick(ev) {
    var url = $(this).data('editPath');
    if (url == null || url.length==0) {
      return;
    }

    $.ajax({ url: url });
  }

  window.Schedule.Grid = {
    init: init,
    initGridDay: initGridDay,
    initTimeSlot: initTimeSlot,
    initBulkDialog: initBulkCreateDialog
  };

})(jQuery, window);

$(function() {
  window.Schedule.Grid.init();
});
