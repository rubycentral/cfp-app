$(function() {
  // Track editing
  $('#edit-track-icon').click(function() {
    $('#current-track').hide();
    $('#edit-track-wrapper').show();
  });

  $('#cancel-track-editing').click(function() {
    $('#edit-track-wrapper').hide();
    $('#current-track').show();
  });

  // Format editing
  $('#edit-format-icon').click(function() {
    $('#current-format').hide();
    $('#edit-format-wrapper').show();
  });

  $('#cancel-format-editing').click(function() {
    $('#edit-format-wrapper').hide();
    $('#current-format').show();
  });

  var autocompleteEl = document.getElementById('autocomplete-options');
  var reviewTagsEl = document.getElementById('proposal_review_tags');
  if(autocompleteEl && reviewTagsEl) {
    var html = autocompleteEl.innerHTML;
    var data = JSON.parse(html);
    var items = data.map(function(x) { return { item: x }; });

    new TomSelect(reviewTagsEl, {
      delimiter: ',',
      persist: false,
      plugins: ['remove_button'],
      options: items,
      valueField: 'item',
      labelField: 'item',
      searchField: 'item',
      create: function(input) {
        return {
            value: input,
            text: input,
            item: input
        }
      }
    });
  }
});
