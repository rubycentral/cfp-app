$(document).ready(function () {
    $('textarea.mention').mentionsInput({
        showAvatars: false,
        minChars: 1,
        elastic: false,

        onDataRequest: function(mode, query, callback) {
            var data = formattedMentionNames($(this).data("mention-names"))

            data = _.filter(data, function(item) { return item.name.toLowerCase().indexOf(query.toLowerCase()) > -1 });

            callback.call(this, data);
        }
    })

    function formattedMentionNames(mentionNames) {
        return _.map(_.compact(mentionNames), function(mentionName) {
        	return { name: "@" + mentionName, type: 'default', id: 1 }
        })
    }
});
