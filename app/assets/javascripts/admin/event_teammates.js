$(document).ready(function() {

  autocompleteNode = $('#autocomplete-email');
  if (autocompleteNode.length > 0) {
    autocompleteNode.autocomplete({
      minLength: 1,
      source: autocompleteNode.data('path')
    });
  }
});
