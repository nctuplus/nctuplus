//
// tag-cale.js 
//  
// Jobs:
// create/delete tag-cale html/css from input data
//
// Js import directive for RoR:
//= require calendar/calendar.js
//= require calendar/event-loader.js
//= require calendar/add-event.js


var tagCale = {

      
  /**
   * 按下月曆中日期後全部的動作。
   */
  setTagCale: function(toDate) {
    tagCale.setDate(toDate);
    tagCale.clear();

    tagCale.addEventToDate(toDate);
  },

  /**
   * 清除tag-cale中所有HTML。
   */
  clear: function() {
    $('.thing-cale').remove();
  },


  /**
   * 顯示選擇的日期
   */
  setDate: function(toDate){

    var month = toDate.getMonth()+1;
    var date = toDate.getDate();
    var wday = toDate.getDay();

    var weekday = new Array(7);
    weekday[0] = "SUN";
    weekday[1] = "MON";
    weekday[2] = "TUE";
    weekday[3] = "WED";
    weekday[4] = "THU";
    weekday[5] = "FRI";
    weekday[6] = "SAT";

    var EngWday = weekday[wday];

    $('.today-sel').html('<h2>[ ' + month + '月' + date + '日' + EngWday + ' ]</h2>');


  },



  //傳入日期抓該日的event
  addEventToDate: function(toDate) {
    forAddEvent.addEventToDate(toDate, 1, 'cale');
  },



}