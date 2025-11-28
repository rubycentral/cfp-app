$(document).ready(function () {
    $('textarea.mention').mentionsInput({
        showAvatars: false,
        minChars: 1,
        elastic: false,

        onDataRequest: function(mode, query, callback) {
            var data = formattedMentionNames($(this).data("mention-names"))

            data = data.filter(function(item) { return item.name.toLowerCase().indexOf(query.toLowerCase()) > -1 });

            callback.call(this, data);
        }
    })

    function formattedMentionNames(mentionNames) {
        return (mentionNames || []).filter(Boolean).map(function(mentionName) {
        	return { name: "@" + mentionName, type: 'default', id: 1 }
        })
    }
});
