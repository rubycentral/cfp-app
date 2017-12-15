$(function() {
    if ($("#copy-filtered-speaker-emails").length) {
        $('#copy-filtered-speaker-emails').on('click', copySpeakerEmails)
    }

    function copySpeakerEmails(e) {
        e.preventDefault()
        var text = $.map($("#program-sessions tbody tr"), function(row) { return JSON.parse(row.dataset.emails) }).join(", ")
        var node = createNode(text)
        document.body.appendChild(node)
        copyNode(node)
        document.body.removeChild(node)
        notifyEmailsCopied()
    }

    function createNode(text) {
        var node = document.createElement('pre')
        node.style.width = '1px'
        node.style.height = '1px'
        node.style.position = 'fixed'
        node.style.top = '5px'
        node.textContent = text
        return node
    }

    function copyNode(node) {
        var selection = getSelection()
        selection.removeAllRanges()

        var range = document.createRange()
        range.selectNodeContents(node)
        selection.addRange(range)

        document.execCommand('copy')
        selection.removeAllRanges()
    }

    function notifyEmailsCopied() {
        var $flash = $("<div class='container alert alert-dismissable alert-info'></div>")
        $flash.html("<p class='text-center'>emails copied to clipboard</p>")
        var $closeButton = $("<button class='close' data-dismiss='alert'></button")
        $closeButton.html("<span class='glyphicon glyphicon-remove'></span>")
        $flash.prepend($closeButton)
        $('#flash').append($flash)
    }

})
