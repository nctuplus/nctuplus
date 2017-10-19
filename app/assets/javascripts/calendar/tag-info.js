//
// tag-info.js 
//  
// Jobs:
// create/delete tag-info html/css from input data
//
// Js import directive for RoR:
//= require calendar/calendar.js
//= require calendar/event-loader.js
//= require calendar/add-event.js


var tagInfo = {

      
  /**
   * 按下月曆中日期後全部的動作。
   */
  setTagInfo: function(toDate) {
    tagInfo.clear();

    tagInfo.addEventToDate(toDate);
  },

  /**
   * 清除tag-cale中所有HTML。
   */
  clear: function() {
    $('.thing-info').remove();
  },


  //傳入日期抓該月和上個月的event
  //抓該月和上個月的e3公告event
  addEventToDate: function(toDate) {
    forAddEvent.addEventToDate(toDate, 1, 'info');
  }



}