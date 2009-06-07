/*
  TODO: I really I have no idea what good jquery looks like or how people lay it out.
  TODO: Modularize as fn.site.controller?
*/
(function ($) {
  // TODO: fn.oursignal.users ?
  $.extend($.fn, {
    feed: function () {
      $('#feed_url').focus();
      $('#feed_add').click(add);
      $('#feed').submit(add);
      $.getJSON('/feeds', function (json) {json.map(score)});
    }
  });

  function add() {
    // TODO: Post #feed_url return {:url => 'http://...', :score => '50'}
    var url = $('#feed_url');
    $.post('/feeds', {url: url.attr('value')}, score, 'json');
    url.attr('value', '').focus();
    return false;
  }

  function score(json) {
    var li = $('<li />').append(control(json), feed(json)).hide();
    $('#scores').prepend(li);
    li.slideDown('slow');
  }

  function feed(json) {
    return json.feed.url;
  }

  function control(json) {
    return $('<div class="control" />').append(slider(json));
  }

  function slider(json) {
    return $('<div class="score" />').slider({value: json.score, stop: function (e, ui) {
      $.post('/feeds/' + json.feed_id, {score: ui.value, _method: 'put'}, 'json');
    }});
  }

  $(document).ready(function () {
    $('#feeds').feed();
  });
})(jQuery);

