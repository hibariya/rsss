// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function(){
 
  // for /:user route
  var max_width = 100;
  $('ul.recent_entries li img').each(function(){
    $(this).hide();
    $(this).load(function(){
      var width = $(this).width();
      var height = $(this).height();
      if (width > max_width) {
        var ratio = (height / width);
        var new_width = max_width;
        var new_height = (new_width * ratio);
        $(this).height(new_height).width(new_width);
      }
      $(this).show('slow');
    });
  });
});
