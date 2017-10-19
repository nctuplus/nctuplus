//
// tag-bell.js 
//  
// Jobs:
// create/delete tag-bell html/css from input data
//
// Js import directive for RoR:
//= require calendar/calendar.js
//= require calendar/event-loader.js
//= require calendar/add-event.js


var tagBell = {


  //tag-bell被呼叫要做的所有動作
  setTagBell: function(toDate){
    tagBell.clear();

    $(`<div class="count-down">`).appendTo('.tag-bell');
    tagBell.addEventWannaDate(toDate);
  },


  /**
   * 清除tag-bell中所有HTML。
   */
  clear: function() {
    $('.count-down').remove();
    $('.e3').remove();
  },

 
 
  
  //決定要抓哪幾天的event
  addEventWannaDate: function(toDate) {

    var now = new Date();
    var nowday = now.getDay();
    var weekday = new Array(7);
    weekday[0] = "週日";
    weekday[1] = "週一";
    weekday[2] = "週二";
    weekday[3] = "週三";
    weekday[4] = "週四";
    weekday[5] = "週五";
    weekday[6] = "週六";

    tagBell.addEventToDate(toDate, "就是今天");
    toDate.setDate(toDate.getDate()+1);
    tagBell.addEventToDate(toDate, "就在明天");
    toDate.setDate(toDate.getDate()+1);
    tagBell.addEventToDate(toDate, "倒數2天");
    toDate.setDate(toDate.getDate()+1);
    tagBell.addEventToDate(toDate, "倒數3天");
    toDate.setDate(toDate.getDate()+1);
    tagBell.addEventToDate(toDate, "倒數4天");
    toDate.setDate(toDate.getDate()+1);
    tagBell.addEventToDate(toDate, "倒數5天");
    toDate.setDate(toDate.getDate()+1);
    tagBell.addEventToDate(toDate, "倒數6天");
    for(var i=0; i<7; i++){
       toDate.setDate(toDate.getDate()+1);
       var theday = toDate.getDay();
       var theword = (theday >= nowday || theday==0) ? "下" : "下下"; //判斷是(下週/下下週)的星期幾
       tagBell.addEventToDate(toDate, theword+weekday[theday]);
    }
    for(var i=0; i<7; i++){
       toDate.setDate(toDate.getDate()+1);
       var theday = toDate.getDay();
       var theword = (theday >= nowday || theday==0) ? "下下" : "下下下"; //判斷是(下週/下下週)的星期幾
       tagBell.addEventToDate(toDate, theword+weekday[theday]);
    }
    for(var i=0; i<7; i++){
       toDate.setDate(toDate.getDate()+1);
       tagBell.addEventToDate(toDate, "三週後");
    }      
    for(var i=0; i<30; i++){
       toDate.setDate(toDate.getDate()+1);
       tagBell.addEventToDate(toDate, "一個月後");
    }
    for(var i=0; i<150; i++){
       toDate.setDate(toDate.getDate()+1);
       tagBell.addEventToDate(toDate, "很久之後");
    }
  },


  //呼叫add-event的addEventToDate
  addEventToDate: function(toDate, dayCount) {
    forAddEvent.addEventToDate(toDate, dayCount, 'bell');
  },

}