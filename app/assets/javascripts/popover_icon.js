$(document).ready(function() {
  // Initialize popovers with Bootstrap 5 API
  document.querySelectorAll("[data-bs-toggle='popover']").forEach(function(el) {
    new bootstrap.Popover(el, { html: true, trigger: 'manual' });
  });

  // Manually show the popover for clicked-on element, and dismiss all
  // other popovers when new one displayed.
  $(document).on('click', '.popover-trigger', function(ev) {
    var selector = $(this).data('target');
    var toggleEl = document.querySelector(selector);
    document.querySelectorAll("[data-bs-toggle='popover']").forEach(function(pop) {
      var popover = bootstrap.Popover.getInstance(pop);
      if (popover) {
        if (pop === toggleEl) {
          popover.toggle();
          var tip = popover.tip;
          if (tip) tip.classList.add('active-popover');
        } else {
          popover.hide();
        }
      }
    });
  });

});
