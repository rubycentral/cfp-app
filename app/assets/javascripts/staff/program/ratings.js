$(document).ready(function () {
    if ($('#rating-form').length) {
        showRating()
        listenForRatingChange()
        $("#rating-tooltip-toggle").on("click", function(e) { e.preventDefault() })
    }
})

function listenForRatingChange() {
    $('.star-rating-select').on('change', onStarRatingChange)
    $('.star-rating-select').not(".delete").on('mouseenter', onStarRatingChoose)
    $('.star-rating').on('mouseleave', showRating)
    $('.star-rating-select.delete').on('mouseenter', showPreviewDelete)
    $('.star-rating-select.delete').on('mouseleave', hidePreviewDelete)
    $('.abstain').on('click', toggleCommentsAndRatings)
}

function onStarRatingChange(e) {
    var $this = $(this)
    e.preventDefault()

    if ($this.data('requestProcessing')) {
        return;
    }

    $this.data('requestProcessing', true)

    var data =  { rating: { score: this.value } }
    var $programTracker = $('input:hidden#program')
    if ($programTracker.length) {
        data.program = $programTracker.val()
    }
    $.ajax({
        url: $this.parents('form')[0].action,
        method: $this.parents('form').hasClass('new_rating') ? 'post' : 'patch',
        data: data,
        success: function () {
            showRating()
            toggleComments($this.val(), $programTracker)
        },
        complete: function() {
            $this.data('requestProcessing', false)
            listenForRatingChange()
        }
    })
}

function onStarRatingChoose() {
    $(this).siblings().find(".fa-star").addClass("starred")
    $(this).closest(".star-wrapper").nextAll().find(".star .fa-star").removeClass("starred")
    $(this).closest(".star-wrapper").prevAll().find(".star .fa-star").addClass("starred")
}

function showRating() {
    $(".star-wrapper").has("input:checked").find(".star .fa-star").addClass("starred")
    $(".star-wrapper").has("input:checked").prevAll().find(".star .fa-star").addClass("starred")
    $(".star-wrapper").has("input:checked").nextAll().find(".star .fa-star").removeClass("starred")
    if ($(".star-wrapper").has("input:checked").length == 0) {
        $(".star-wrapper .fa-star").removeClass("starred")
    }
    setupPopover()
}

function showPreviewDelete() {
    $(this).closest('ul').addClass('preview-delete')
}

function hidePreviewDelete() {
    $(this).closest('ul').removeClass('preview-delete')
}

function toggleComments(rating, programTracker) {
    if (!rating && !programTracker.val()) {
        $(".internal-comments").addClass("hidden")
    } else {
        $(".internal-comments").removeClass("hidden")
    }
}

function toggleCommentsAndRatings(e) {
    e.preventDefault()
    $.each($(this).find("i"), function () {
        $(this).toggleClass('hidden')
    })
    $(".internal-comments").toggleClass("hidden")
    $("#show-ratings").toggleClass("hidden")
}

function setupPopover() {
    $('.popover').remove()
    $('#rating-tooltip-toggle').popover({})
}
