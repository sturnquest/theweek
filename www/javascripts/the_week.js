function swipe_page(to_page_id, slide_right_to_left) {
    change_page(to_page_id, slide_right_to_left, 'slide');

}

function change_page(to_page_id, reverse_transition, transition) {
    // JQuery mobile does not work properly for changing pages to an internal div.
    // See: http://forum.jquery.com/topic/changepage-not-updating-hash-for-internal-div-pages
    // To workaround supply a all parameters for page transition.
    $.mobile.changePage(to_page_id, transition, reverse_transition, true);
    e.stopImmediatePropagation();
    return false;
}

$(function() {

    $('.page').bind('swipeleft', function(e) {
        swipe_page($.mobile.activePage.attr('data-next-page'), false);
    });

    $('.page').bind('swiperight', function(e) {
        swipe_page($.mobile.activePage.attr('data-prev-page'), true);
    });

    // Disable up/down scrolling so that it mimics behavior of a native iOS app and not a WebKit control inside a container
    // see: http://wiki.phonegap.com/w/page/16494815/Preventing-Scrolling-on-iPhone-Phonegap-Applications
    $('body').bind('touchmove', function(e) {
        e.preventDefault();
    });

    $('.page-bookmark a').click(function() {
        alert('Bookmark page: ' + $.mobile.activePage.attr('id'));

        var bookmark = $.mobile.activePage.attr('id');
        var bookmarks = localStorage["bookmarks"];
        if (bookmarks == null) {
            bookmarks = bookmark;
        } else {
            bookmarks += ',' + bookmark;
        }

        localStorage["bookmarks"] = bookmarks;
    });

    $('#contents-bookmark').click(function() {

        $('#bookmark-container .bookmark-row').remove();

        var bookmarks = localStorage["bookmarks"];
        if (bookmarks != null) {
            var pages = bookmarks.split(",");
            for (var i = 0; i < pages.length; i++) {
                var bookmarkRow = $('#bookmark_template').clone();
                var bookmarkLink = bookmarkRow.find('.bookmark-title');
                bookmarkLink.text(pages[i]);
                bookmarkLink.attr('href', '#' + pages[i]);
                bookmarkRow.appendTo('#bookmark-container');
            }
        }

        $('.remove-bookmark').click(function() {
            var bookMarkPageId = $(this).prev().text();
            $(this).parent().remove();
            var existingBookmarks = localStorage["bookmarks"].split(',');
            var remainingBookmarks = '';
            for (var i = 0; i < existingBookmarks.length; i++) {
                var existingBookmarkPageId = existingBookmarks[i];
                if (bookMarkPageId != existingBookmarkPageId) {
                    remainingBookmarks += existingBookmarkPageId + ',';
                }
            }

            localStorage["bookmarks"] = remainingBookmarks;
        });

        change_page('#bookmarks', false, 'slideup');
    });

});