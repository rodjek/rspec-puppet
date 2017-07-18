$(document).ready(function() {
    var sidebarMenu = $('#doc-nav .doc-menu');
    var pageContent = $('.doc-content');

    pageContent.find('h2').each(function() {
        var titleText = $(this).clone().children().remove().end().text();
        sidebarMenu.append('<li id="' + $(this).attr('id') + '-menu"><a class="scrollto" href="#' + $(this).attr('id') + '">' + titleText + '</a></li>');
    });
    pageContent.find('h3').each(function() {
        prevTitle = sidebarMenu.find('#' + $(this).prevAll('h2').first().attr('id') + '-menu');
        prevTitle.not(":has(ul)").append('<ul class="nav doc-sub-menu"></ul>');
        prevTitle.find('.doc-sub-menu').append('<li id="' + $(this).attr('id') + '-menu"><a class="scrollto" href="#' + $(this).attr('id') + '">' + $(this).html() + '</a></li>');
    });
});
