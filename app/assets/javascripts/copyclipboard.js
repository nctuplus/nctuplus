function setCopyToClipboardOnClick(elem, copiedMsg) {
    $(elem).click(function() {
        value = $(this).data('clipboard-text');
        var $temp = $('<input>');
        $("body").append($temp);
        $temp.val(value).select();
        document.execCommand("copy");
        $temp.remove();

        toastr["success"](copiedMsg);
    });
}
