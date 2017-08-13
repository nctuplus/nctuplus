//
// index.js 
//  
// Jobs:
// Page initialization
// Install event callback
// Controll how all js in this page work together
//
// Js import directive for RoR:
//= require calendar/event-loader.js
//= require calendar/calendar.js
//= require calendar/info-bar.js
//= require calendar/callback.js
//
var d = new Date();
eventLoader.getEventByMonth(d.getFullYear(), d.getMonth()+1);

var pageInitialization = function() {
  $("#cal-date").hide().fadeIn(500);

  calendar.setup();

  $(".tag-cale").hide();
  $(".tag-info").hide();
  $("#btn-bell").addClass("selected");
}


$(document).ready(function(){

  pageInitialization();

  // Install callbacks
  $("#btn-cale").click(callback.cale_click);
  $("#btn-info").click(callback.info_click);
  $("#btn-bell").click(callback.bell_click);

  $("#bar1").click(callback.bar1_click);
  $("#bar2").click(callback.bar2_click);
  $("#bar3").click(callback.bar3_click);
  $("#bar4").click(callback.bar4_click);
  $("#bar5").click(callback.bar5_click);

  var btns = $('#cal-month .btn-month');
  $(btns[0]).click(calendar.preMonth);
  $(btns[1]).click(calendar.nxtMonth);
  $('.tag-bell .today').click(calendar.thisMonth);
/*
  $('.content').popover({
        content: $(".content").html(),
        placement:"auto",
        trigger : "hover",
      });

*/
//  var hey = new Date(1498581000000);
//  alert(hey);

});
