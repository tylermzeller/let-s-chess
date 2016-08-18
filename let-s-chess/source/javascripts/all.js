// require_tree .

$(document).ready(function(e){
  $('.sb-button').hover(function(e){
    var labels = $('#sidebar-wrapper').find('.sb-label');
    var label = $(this).parent().find('.sb-label');
    label.addClass('select');
    labels.addClass('hover');
  },
  function(e){
    var labels = $('#sidebar-wrapper').find('.sb-label');
    var label = $(this).parent().find('.sb-label');
    label.removeClass('select');
    labels.removeClass('hover');
  });

});
