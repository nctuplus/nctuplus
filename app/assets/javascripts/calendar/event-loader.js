//
// event-loader.js 
//  
// Jobs:
// Parse data from server.
// Implement lazy loading for event data.
// 動態下載月曆資料，只下載月曆範圍顯示的資料
// 
var eventLoader = {

  events: {},

  /**
   * 轉換Date型態到包含此時間範圍的Event Index
   * @param {Date} time - 時間
   */
  timeToIndex: function(time) {
    return time.getFullYear()*100 + time.getMonth()+1; // ex: 2017/5 => 201705
  },

  /**
   * getEvent函數的回調函數
   *
   * @callback getEventCallback
   * @param {Array.} data - 範圍內的資料的陣列
   * @param {object} param - 呼叫getEvent時的自定義參數
   */
  /**
   * 取得指定時間範圍的資料，功課公告以結束時間作為時間判斷標準，
   * 活動以開始時間作為時間判斷標準，取得後呼叫callback函數。
   * @param {Date} start - 開始時間
   * @param {Date} end - 結束時間
   * @param {getEventCallback} callback - 取得的資料要傳入的函數
   * @param {object} param - 要傳入callback的參數
   */
  getEvent: function(start, end, callback, param) {
    
    if (eventLoader.isLoaded(start,end)) {
      if (typeof(callback) == 'function')
        callback(eventLoader._filterEvent(start,end), param);
      return true;
    }
    eventLoader.getEventFromServer(start, end, callback, param);
    return false;
  },

  /**
   * 從Server取得指定時間範圍的資料，取得後呼叫callback函數。
   * @param {Date} start - 開始時間
   * @param {Date} end - 結束時間
   * @param {getEventCallback} callback - 取得的資料要傳入的函數
   * @param {object} param - 要傳入callback的自定義參數
   */
  getEventFromServer: function(start, end, callback, param) {
    if(start > end) return;
    if (typeof(callback) == 'function')
      eventLoader._latestGetEventID++;

    var s = new Date(start.getFullYear(), 
                     start.getMonth(),
                     1, 0, 0, 0, 0);
    var e = new Date(end.getFullYear(), 
                     end.getMonth()+1,
                     0, 23, 59, 59, 999);
    $.ajax({
      url: '/calendar/get_event',
      type: 'POST',
      data: {start:s.getTime(), end: e.getTime()},
      success: eventLoader._makeGetEvent_success(start, end, callback, param, eventLoader._latestGetEventID),
      error: eventLoader._makeGetEvent_error(start, end, callback, param, eventLoader._latestGetEventID),
    });
    return;
  },

  /**
   * 初始化儲存指定月份範圍的陣列
   * @param {Date} start - 開始月份
   * @param {Date} end - 結束月份
   */
  initEventMonth: function(start, end) {
    for (var year = start.getFullYear(); year <= end.getFullYear(); year++) {
      var month = (year==start.getFullYear())? start.getMonth(): 0;
      var stopMonth = (year==end.getFullYear())? end.getMonth(): 11;
      for (; month <= stopMonth; month++) {
        var index = year*100 + month+1; // ex: 2017/5 => 201705
        eventLoader.events[index] = []; // 放入空陣列
      }
    }
  },

  /**
   * 判斷指定時間範圍的資料是否都已下載過
   * @param {Date} start - 開始時間
   * @param {Date} end - 結束時間
   * @return {boolean} true代表已完全下載，false代表有未下載的部分
   */
  isLoaded: function(start, end) {
    for (var year = start.getFullYear(); year <= end.getFullYear(); year++) {
      var month = (year==start.getFullYear())? start.getMonth(): 0;
      var stopMonth = (year==end.getFullYear())? end.getMonth(): 11;
      for (; month <= stopMonth; month++) {
        var index = year*100 + month+1; // ex: 2017/5 => 201705
        if (eventLoader.events[index] === undefined)
          return false;
      }
    }
    return true;
  },


  // Private Member
  _latestGetEventID: 0,
  _makeGetEvent_success: function(start, end, callback, param, getEventID) {
    return function(data) {
      eventLoader.initEventMonth(start,end);

      // 將所有資料依月份放入events中
      for (var i = 0; i < data.length; i++) {
        // 將時間從Unix Timestamp轉換成Date型態
        data[i].TimeStart = new Date(data[i].TimeStart);
        data[i].TimeEnd = new Date(data[i].TimeEnd);
        // 依照事件類型決定用開始時間或結束時間
        var time = (data[i].MaterialType == 'event')? data[i].TimeStart: data[i].TimeEnd;
        var index = eventLoader.timeToIndex(time);
        eventLoader.events[index].push(data[i]);
      }
      // 判斷最新的getEventID跟傳入的一樣才呼叫callback
      // 避免月曆在資料還沒回傳前又切換月份，影響頁面載入
      if(typeof(callback) == 'function' && getEventID === eventLoader._latestGetEventID)
        callback(eventLoader._filterEvent(start,end), param);
    }
  },
  _makeGetEvent_error: function(start, end, callback, param, getEventID) {
    return function() {
      // 如果沒有其他的getEvent，1秒後重新下載資料
      if(typeof(callback) == 'function' && getEventID === eventLoader._latestGetEventID) {
        setTimeout(function(){ 
          getEventFromServer(start, end, callback, param); 
        }, 1000);
      }
    }
  },
  _filterEvent: function(start, end) {
    var retList = [];

    // 處理首月跟尾月哪些事件要放入list的小函數
    function firstLastHandler(t) {
      var index = eventLoader.timeToIndex(t);
      if( eventLoader.events[index] )
        eventLoader.events[index].forEach(function firstLastHandler(elem) {
          var time = (elem.MaterialType == 'event')? elem.TimeStart: elem.TimeEnd;
          if(start <= time && time <= end )
            retList.push(elem);
        });
    }

    // 首月&尾月
    firstLastHandler(start);
    if(start.getFullYear() != end.getFullYear() || start.getMonth() != end.getMonth()) {
      firstLastHandler(end);
    }

    // 中間月
    var s = new Date(start.getFullYear(), start.getMonth()+1, 1);
    var e = new Date(end.getFullYear(), end.getMonth()-1, 1);
    for (var year = s.getFullYear(); year <= end.getFullYear(); year++) {
      var month = (year==s.getFullYear())? s.getMonth(): 0;
      var stopMonth = (year==e.getFullYear())? e.getMonth(): 11;
      for (; month <= stopMonth; month++) {
        var index = year*100 + month+1; // ex: 2017/5 => 201705
        retList = retList.concat(eventLoader.events[index]); 
      }
    }
    return retList;
  }

}