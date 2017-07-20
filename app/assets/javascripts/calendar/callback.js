//
// callback.js 
//  
// Jobs:
// Handle reactions for different event
//

var callback = {
  info_click: function() {
    $(".tag-cale").fadeOut();
    $(".tag-info").fadeIn();
    $(".tag-bell").fadeOut();
    $("#btn-cale").removeClass("selected");
    $("#btn-info").addClass("selected");
    $("#btn-bell").removeClass("selected");
  },

  bell_click: function() {
    $(".tag-cale").fadeOut();
    $(".tag-info").fadeOut();
    $(".tag-bell").fadeIn();
    $("#btn-cale").removeClass("selected");
    $("#btn-info").removeClass("selected");
    $("#btn-bell").addClass("selected");
  },

  cale_click: function() {
    $(".tag-cale").fadeIn();
    $(".tag-info").fadeOut();
    $(".tag-bell").fadeOut();
    $("#btn-cale").addClass("selected");
    $("#btn-info").removeClass("selected");
    $("#btn-bell").removeClass("selected");
  },

  bar1_click: function() {
    $("#bar1").nextAll().toggle("fast");
  },
  bar2_click: function() {
    $("#bar2").nextAll().toggle("fast");
  },
  bar3_click: function() {
    $("#bar3").nextAll().toggle("fast");
  },
  bar4_click: function() {
    $("#bar4").nextAll().toggle("fast");
  },
  bar5_click: function() {
    $("#bar5").nextAll().toggle("fast");
  },

  dateBox_click: function(event) {

    var date = event.data;
    calendar.selectDate(date);

  },

  getEvent_callback: function(data) {
    console.log(data);
  } 
}