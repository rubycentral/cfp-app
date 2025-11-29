$(document).ready(function () {
    document.querySelectorAll('textarea.mention').forEach(function(el) {
        var mentionNames = JSON.parse(el.dataset.mentionNames || '[]') || [];
        var values = mentionNames.filter(Boolean).map(function(name) {
            return { key: name, value: name };
        });

        var tribute = new Tribute({
            trigger: '@',
            values: values,
            selectTemplate: function(item) {
                return '@' + item.original.value;
            },
            menuItemTemplate: function(item) {
                return '@' + item.original.value;
            },
            noMatchTemplate: '',
            lookup: 'key',
            fillAttr: 'value'
        });

        tribute.attach(el);
    });
});
