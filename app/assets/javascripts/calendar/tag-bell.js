//
// tag-bell.js 
//  
// Jobs:
// create/delete tag-bell html/css from input data
//
// Js import directive for RoR:
//= require calendar/calendar.js
//= require calendar/event-loader.js


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

  
    /**
     * 傳入event物件繪製出來 
     * @param {number} index - 這一天第幾個事件(從0開始)
     * @param {string} dayCount - 倒數幾天
     */
  addEvent: function(event, index, dayCount) {
    var title;
    var eventTime;
    var content;

    var yy = event.EventTime.getFullYear(), mn = event.EventTime.getMonth()+1, dd = event.EventTime.getDate();
    var hh = event.EventTime.getHours(), mm = event.EventTime.getMinutes(), ss = event.EventTime.getSeconds();


    //判斷event屬性, 以選擇用EventTime或者TimeStart/TimeEnd
    if(event.MaterialType == 'announcement'){
      title = event.CourseName;
      eventTime = ' ' + yy + '-' + mn + '-' + dd;
      content = event.Title;
    }else if(event.MaterialType == 'event'){
      title = event.Title;
      eventTime = ' ' + yy + '-' + mn + '-' + dd + ' ' + (hh<10?'0':'')+hh + ':' + (mm<10?'0':'')+mm + ':' + (ss<10?'0':'')+ss ;
      content = '';
    }else if(event.MaterialType == 'assignment'){
      title = event.CourseName;
      hh = event.TimeEnd.getHours(), mm = event.TimeEnd.getMinutes(), ss = event.TimeEnd.getSeconds();
      yy = event.TimeEnd.getFullYear(), mn = event.TimeEnd.getMonth()+1, dd = event.TimeEnd.getDate();
      eventTime = '  Deadline  ' + yy + '-' + mn + '-' + dd + '   ' + hh + ':' + mm + ':' + ss;
      content = event.Title;
    }else{
      return false;
    }

    if(index == 0) $(`<div class="title-bar">${dayCount}</div>`).appendTo('.count-down');
    var e = $(` <div class="thing">
                    <div class="content"><b>${title}</b><br>
                    <span class="glyphicon glyphicon-time"></span>${eventTime}<br>
                    ${content}</div>
                </div>`).appendTo('.count-down');
    
    switch (event.MaterialType) {
      case 'announcement':
        e.find('.content').addClass('border-darkblue'); break;
      case 'assignment':
        e.find('.content').addClass('border-red'); break;
      case 'event':
        e.find('.content').addClass('border-yellow'); break;
    }
    
    return true;

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


  /**
   * 傳入日期抓該日的event  
   * @param {Date} toDate - 傳入的日期
   * @param {String} dayCount - 倒數幾天
   */
  addEventToDate: function(toDate, dayCount) {

    var Nyear = toDate.getFullYear(), Nmonth = toDate.getMonth(), Nd = toDate.getDate();
    var hasEvent = false;
    
    //直接搜遍所有event 找到符合該日期的event則丟入addEvent()
    var savedEvents = eventLoader.events[Nyear*100+Nmonth+1];
    var index = 0;//記錄這一天有幾個event
    for(var i=0; (savedEvents!==undefined && i<savedEvents.length); i++){
      var tmp = savedEvents[i];
      var year = tmp.EventTime.getFullYear(), month = tmp.EventTime.getMonth(), d = tmp.EventTime.getDate();

      if(Nyear == year && Nmonth == month && Nd == d){
        tagBell.addEvent(tmp, index++, dayCount);
        hasEvent = true;
      }      
    }

  //  if(!hasEvent) $(`<div class="thing-cale"><div class="content">(無事件)</div></div>`).appendTo('.tag-bell');


  },

}