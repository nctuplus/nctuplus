//
// calendar.js 
//  
// Jobs:
// create/delete calendar html/css from input data
//
// Js import directive for RoR:
//= require calendar/event-loader.js
//= require calendar/callback.js
//
var calendar = {
  /**
   * 儲存每個日期的jquery物件
   * ex: dateBox = {
   *       2016: {
   *         11: { // Date.getMonth從0開始
   *           29: $('#db_12_29'),
   *           30: $('#db_12_30'),
   *           31: $('#db_12_31')
   *         } 
   *       },
   *       2017: {
   *         0: {
   *           1: $('#db_1_1'),
   *           2: $('#db_1_2'),
   *           3: $('#db_1_3')
   *         } 
   *       },
   *     }
   */
  dateBox: {}, 
  status: {
    selectedDate: new Date(),
    year: new Date().getFullYear(),
    month: new Date().getMonth()+1,
  },


  /**
   * 清除月曆中所有日期的HTML。
   */
  clear: function() {
    $('#cal-date').children().remove();
    calendar.dateBox = {};
  },

  /**
   * 切換日曆到下個月。
   */
  nxtMonth: function() {
    $("#cal-date").hide().fadeIn(300);
    calendar.setup(calendar.status.year, calendar.status.month+1);
  },

  /**
   * 切換日曆到上個月。
   */
  preMonth: function() {
    $("#cal-date").hide().fadeIn(300);
    calendar.setup(calendar.status.year, calendar.status.month-1);
  },

  /**
   * 切換日曆到今天的月份。
   */
  thisMonth: function() {
    $("#cal-date").hide().fadeIn(300);
    var year = new Date().getFullYear();
    var month = new Date().getMonth()+1;
    calendar.setup(year, month);
  },

  /**
   * 建立指定月份的月曆。
   * @param {number} year - 要建立月曆的年份
   * @param {number} month - 要建立月曆的月份
   */
  setup: function(year, month) {

    // 預設Input
    year = (year === undefined)? calendar.status.year: year;
    month = (month === undefined)? calendar.status.month: month;
    // 處理Input(13月 or -1月)
    year = year + Math.floor((month-1)/12);
    month = (month+11)%12+1;
    calendar.status.year = year;
    calendar.status.month = month;

    // 清除原日曆
    calendar.clear();
    // 畫出新日曆
    calendar.draw(year, month);
    // 選擇日期
    calendar.selectDate(calendar.status.selectedDate);
    // 載入事件
    eventLoader.getEventByMonth(year, month, callback.calendar_getEventCB);
  },

  /**
   * 繪製指定月份的HTML。
   * @param {number} year - 月曆的年
   * @param {number} month - 月曆的月
   */
  draw: function(year, month) {

    // 計算開始日期
    var date = new Date(year, month-1, 1);
    var dayOfFirst = date.getDay();
    date = new Date(year, month-1, -dayOfFirst+1); // date of first Sunday

    // 修改月曆標題時間
    $('#cal-month').find('.sel-month').html(`<h2>${month}月 ${year}</h2>`);

    // 建立 6 週的date-box們
    for (var i = 0; i < 6; i++) {
      var week = $('<div class="week"></div>').appendTo('#cal-date');
      for (var j = 0; j < 7; j++) {
        var curMon = date.getMonth()+1, curDate = date.getDate();
        var dateBox = $(`<div class="date-box" id="db_${curMon}_${curDate}"></div>`).appendTo(week);
        var dateTxt = $(`<div class="date">${curDate}</div>`).appendTo(dateBox);

        if (curMon != month) // 設定非當月class
          dateBox.addClass('not-this-month');
        dateBox.click(new Date(date), callback.dateBox_click); // 綁定點擊事件

        // 儲存dateBox物件到calendar.dateBox
        var y = date.getFullYear(), m = date.getMonth(), d = date.getDate();
        if (calendar.dateBox[y] === undefined)
          calendar.dateBox[y] = {};
        if (calendar.dateBox[y][m] === undefined)
          calendar.dateBox[y][m] = {};
        calendar.dateBox[y][m][d] = dateBox;

        date.setDate(date.getDate()+1); // 下一天
      }
    }

  },

  /**
   * 在日曆選擇日期。
   * @param {Date} toDate - 要選擇的時間
   * @return {boolean} 選取日期是否在目前顯示的月曆範圍內
   */
  selectDate: function(toDate) {
    $('.date-box').removeClass('box-today');
    calendar.status.selectedDate = toDate;

    var prevMonthTime = new Date(calendar.status.year, (calendar.status.month-1)-1, 1);
    var nextMonthTime = new Date(calendar.status.year, (calendar.status.month-1)+1, 28);
    if( toDate<prevMonthTime || toDate>nextMonthTime )
      return false;
    var month = toDate.getMonth(), date = toDate.getDate();
    var dateBox = calendar.getDateBox(toDate).addClass('box-today');
    return (dateBox.length != 0);
  },

  /**
   * 在日曆上新增事件。
   * @param {Event} event - 要新增的事件
   * @return {boolean} 事件時間是否在日曆範圍內，新增成功回傳true，否則回傳false
   */
  addEvent: function(event) {

    var dateBox = calendar.getDateBox(event.EventTime);
    if (dateBox.length == 0)
      return false;
    var e = $(`<div class="event">
                 <div class="rec"></div>
                 <div class="content">${event.Title}</div>
               </div>`).appendTo(dateBox);
    switch (event.MaterialType) {
      case 'announcement':
        e.addClass('rec-yellow'); break;
      case 'homework':
        e.addClass('rec-red'); break;
      case 'event':
        e.addClass('rec-darkblue'); break;
    }
    return true;
  },

  /**
   * 取得DateBox jquery物件。
   * @param {Date} time - 時間
   * @return {object} 回傳找到的object，沒找到則回傳空物件
   */
  getDateBox: function(time) {
    try {
      var year = time.getFullYear(), month = time.getMonth(), d = time.getDate();
      var dateBox = calendar.dateBox[year][month][d];
    } catch (e) {}
    return $(dateBox);
  }

}
