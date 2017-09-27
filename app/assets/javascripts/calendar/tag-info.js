//
// tag-info.js 
//  
// Jobs:
// create/delete tag-info html/css from input data
//
// Js import directive for RoR:
//= require calendar/calendar.js
//= require calendar/event-loader.js


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



  //傳入event物件繪製出來
  addEvent: function(event) {
    var title;
    var eventTime;
    var content;

    var yy = event.EventTime.getFullYear(), mn = event.EventTime.getMonth()+1, dd = event.EventTime.getDate();


    //判斷event屬性, 以選擇用EventTime或者TimeStart/TimeEnd
    if(event.MaterialType == 'announcement'){
      title = event.CourseName;
      eventTime = ' ' + yy + '-' + mn + '-' + dd;
      content = event.Title;
    }else return false;

    var e = $(`<div class="thing-info"><div class="content border-darkblue"><b>${title}</b><br>
      <span class="glyphicon glyphicon-time"></span>${eventTime}<br>
        ${content}</div></div>`).appendTo('.tag-info');
    
    
    
    return true;

  },

  //傳入日期抓該月和上個月的event
  addEventToDate: function(toDate) {


    var Nyear = toDate.getFullYear(), Nmonth = toDate.getMonth(), Nd = toDate.getDate();
    var hasEvent = false;

    //直接搜遍所有該月event
    var savedEvents = eventLoader.events[Nyear*100+Nmonth+1];
    //用時間排序(新到舊)
    savedEvents.sort( function(a, b){return b.EventTime-a.EventTime} );
    for(var i=0; (savedEvents!==undefined && i<savedEvents.length); i++){
      //全部加進去
      var tmp = savedEvents[i];
      tagInfo.addEvent(tmp);
      hasEvent = true;
    }

    //直接搜遍所有上個月event
    savedEvents = eventLoader.events[Nyear*100+Nmonth];
    //用時間排序(新到舊)
    savedEvents.sort( function(a, b){return b.EventTime-a.EventTime} );
    for(var i=0; (savedEvents!==undefined && i<savedEvents.length); i++){
      //全部加進去
      var tmp = savedEvents[i];
      tagInfo.addEvent(tmp);
      hasEvent = true;
    }

    if(!hasEvent) $(`<div class="thing-info"><div class="content">(近期並無公告)</div></div>`).appendTo('.tag-info');


  }



}