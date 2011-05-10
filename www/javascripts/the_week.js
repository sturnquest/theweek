function swipe_page(to_page_id, slide_right_to_left) {
    // JQuery mobile does not work properly for changing pages to an internal div.
    // See: http://forum.jquery.com/topic/changepage-not-updating-hash-for-internal-div-pages
    // To workaround supply a all parameters for page transition.
    $.mobile.changePage(to_page_id, 'slide', slide_right_to_left, true);
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

});