//
// tag-cale.js 
//  
// Jobs:
// create/delete tag-cale html/css from input data
//
// Js import directive for RoR:
//= require calendar/calendar.js
//= require calendar/event-loader.js


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

    $('.today-sel').html(`<h2>[ ${month}月${date}日 ${EngWday} ]</h2>`);


  },




  //傳入event物件繪製出來
  addEvent: function(event) {
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

    var e = $(`<div class="thing-cale"><div class="content"><b>${title}</b><br>
      <span class="glyphicon glyphicon-time"></span>${eventTime}<br>
        ${content}</div></div>`).appendTo('.tag-cale');
    
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

  //傳入日期抓該日的event
  addEventToDate: function(toDate) {


    var Nyear = toDate.getFullYear(), Nmonth = toDate.getMonth(), Nd = toDate.getDate();
    var hasEvent = false;

    //直接搜遍所有event 找到符合該日期的event則丟入addEvent()
    var savedEvents = eventLoader.events[Nyear*100+Nmonth+1];
    for(var i=0; (savedEvents!==undefined && i<savedEvents.length); i++){
      var tmp = savedEvents[i];
      var year = tmp.EventTime.getFullYear(), month = tmp.EventTime.getMonth(), d = tmp.EventTime.getDate();
      if(Nyear == year && Nmonth == month && Nd == d){
        tagCale.addEvent(tmp);
        hasEvent = true;
      }      
    }

    if(!hasEvent) $(`<div class="thing-cale"><div class="content">(無事件)</div></div>`).appendTo('.tag-cale');


  }



}