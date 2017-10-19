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
    tagInfo.setTagInfo(new Date());
  },

  bell_click: function() {
    $(".tag-cale").fadeOut();
    $(".tag-info").fadeOut();
    $(".tag-bell").fadeIn();
    $("#btn-cale").removeClass("selected");
    $("#btn-info").removeClass("selected");
    $("#btn-bell").addClass("selected");
    calendar.selectDate(new Date());
    tagBell.setTagBell(new Date());
  },

  cale_click_direct: function(){
    $(".tag-cale").hide().fadeIn();
    $(".tag-info").fadeOut();
    $(".tag-bell").fadeOut();
    $("#btn-cale").addClass("selected");
    $("#btn-info").removeClass("selected");
    $("#btn-bell").removeClass("selected");
    calendar.selectDate(new Date());
    tagCale.setTagCale(new Date());
  },
  cale_click: function(toDate) {
    $(".tag-cale").hide().fadeIn();
    $(".tag-info").fadeOut();
    $(".tag-bell").fadeOut();
    $("#btn-cale").addClass("selected");
    $("#btn-info").removeClass("selected");
    $("#btn-bell").removeClass("selected");
    calendar.selectDate(toDate);
    tagCale.setTagCale(toDate);
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
    callback.cale_click(event.data);//switch to tag-cale
  },


  calendar_getEventCB: function(data) {
    for (var i = 0; i < data.length; i++) {
      calendar.addEvent(data[i]);
    }
    
    tagBell.setTagBell(new Date());
  }
}