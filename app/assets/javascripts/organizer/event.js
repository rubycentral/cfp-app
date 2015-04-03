$(document).ready(function() {

$('.checkbox').on('change', function() { $(this).closest('form').submit(); });

});
