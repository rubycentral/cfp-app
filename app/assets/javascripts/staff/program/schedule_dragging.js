(function($, window) {
    if (typeof(window.Schedule) === 'undefined') {
        window.Schedule = {}
    }
    if (typeof(window.Schedule.Drag) !== 'undefined') {
        return window.Schedule.Drag
    }

    function init() {
        if ($(".unscheduled-sessions").length ) {
            $('.unscheduled-sessions-toggle').on('click', toggleUnscheduledSessionsWidget)
            $('input[name="session_search"]').on('keyup', filterSessions)

            var trackCssClasses = [];
            var trackColors = [];

            initTrackColors()
            initDraggableSessions()
            initDroppableSessionsWidget()
        }
    }

    function toggleUnscheduledSessionsWidget(e) {
        e.preventDefault()
        $('.unscheduled-sessions-widget, .search-sessions-wrapper').toggleClass('hidden')
    }

    function filterSessions() {
        var query = this.value.toLowerCase()
        var items = $('.unscheduled-sessions-widget .draggable-session-card')

        for (var i = 0; i < items.length; i++) {
            var itemText = $(items[i]).text().toLowerCase()
            if (itemText.indexOf(query) > -1) {
                $(items[i]).removeClass('hidden')
            } else {
                $(items[i]).addClass('hidden')
            }
        }
    }

    function initTrackColors() {
        trackCssClasses = $('#schedule').data('tracks-css');
        trackColors = palette('tol-rainbow', trackCssClasses.length);
    }

    function initDraggableSessions() {
        var $sessions = $('.draggable-session-card')
        $sessions.each(function(i, session) {
            initDraggableSession($(session))
        })
    }

    function initDraggableSession($session) {
        var trackCss = $session.data('trackCss')
        var i = trackCssClasses.indexOf(trackCss)
        if (i >= 0) {
            $session.find('.track').css({
                backgroundColor: '#' + trackColors[i]
            })
        }
        $session.draggable({
            helper: 'clone',
            revertDuration: 100,
            revert: 'invalid',
            appendTo: 'body',
            scroll: false,
            start: function(event, ui) {
                $(ui.helper).css({ backgroundColor: 'white' })
            }
        })
        var scheduled = $session.data('scheduled')
        $session.attr({
          'data-toggle': scheduled ? null : 'modal',
          'data-target': scheduled ? null : '#program-session-show-dialog'
        })
        $session.on('click', showProgramSession)
    }

    function showProgramSession() {
      var url = $(this).data('showPath')
      var scheduled = $(this).data('scheduled')
      if (url && !scheduled) {
        $.ajax({url: url})
      }
    }

    function initDroppableSessionsWidget() {
        $('.unscheduled-sessions-widget').droppable({
            accept: '.draggable-session-card',
            drop: function(event, ui) {
                $(ui.draggable).detach().removeAttr('style').prependTo(this)
                $(ui.draggable).removeClass('small medium large')
                if ($(ui.draggable).data('scheduled')) {
                    unschedule($(ui.draggable))
                }
            }
        })
    }

    function unschedule($removed) {
      $.ajax({
        url: $removed.data('unscheduleTimeSlotPath'),
        method: 'patch',
        data: { time_slot: { program_session_id: '' } },
        success: function(data) {
          $(".unscheduled-sessions-toggle .badge").text(
            data.unscheduled_count + "/" + data.total_count
          )
          $(".total.time-slots .badge").each(function(i, badge) {
            var counts = this.day_counts[i + 1]
            $(badge).text(counts.scheduled + "/" + counts.total)
          }.bind(data))
        },
      })
      $removed.data('scheduled', null)
      $removed.attr({
        'data-scheduled': null,
        'data-toggle': 'modal',
        'data-target': '#program-session-show-dialog'
      })
      $removed.on('click', showProgramSession)
    }

    window.Schedule.Drag = {
      initDraggableSession: initDraggableSession,
      unschedule: unschedule,
      init: init,
      showProgramSession: showProgramSession,
    }


}) (jQuery, window)

$(function() {
    window.Schedule.Drag.init()
})
