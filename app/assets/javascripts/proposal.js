$(function() {
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
