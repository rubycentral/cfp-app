(function($, window) {
  if (typeof(window.Utilities) !== 'undefined') {
    return window.Utilities;
  }

  function clearFields(fields, opt_parent) {
    var parentNode = opt_parent === undefined ? null : $(opt_parent);

    var node;
    for(var i = 0; i < fields.length; ++i) {
      if (parentNode !== null) {
        node = parentNode.find(fields[i]);
      } else {
        node = $(fields[i]);
      }

      node.val('');
    }
  }

  window.Utilities = {
    clearFields: clearFields
  };

})(jQuery, window);
