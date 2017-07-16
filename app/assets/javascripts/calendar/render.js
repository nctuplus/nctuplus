//
// render.js 
//  
// Jobs:
// create/delete html/css from input data
//
var calendar = {
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

  },

  /**
   * 繪製指定月份的HTML。
   * @param {number} year - 月曆的年
   * @param {number} month - 月曆的月
   */
  draw: function(year, month) {

    // 計算開始日期
    var date;
    date = new Date(year, month-1, 1);
    var dayOfFirst = date.getDay();
    date = new Date(year, month, 0);
    var dateOfLast = date.getDate();
    date = new Date(year, month-1, -dayOfFirst+1);
    var dateOfFirstSunday = date.getDate();

    // 修改月曆標題時間
    $('#cal-month').find('.sel-month').html(`<h2>${month}月 ${year}</h2>`);

    // 建立 6 週的date-box們
    for (var i = 0; i < 6; i++) {
      var week = $('<div class="week"></div>').appendTo('#cal-date');
      for (var j = 0; j < 7; j++) {
        var dateBox = $('<div class="date-box"></div>').appendTo(week);
        var date = dateBox.append('<div class="date"></div>');
      }
    }

    // 寫上日期、非當月的date-box設定class: not-this-month
    var index, boxes = $('#cal-date').find('.date-box');
    // 上月
    var prevMonth = (month-1+11)%12+1;
    for (index=0, date=dateOfFirstSunday; index<dayOfFirst; index++,date++) {
      $(boxes[index]).attr('id', `db_${prevMonth}_${date}`);
      $(boxes[index]).addClass('not-this-month');
      $(boxes[index]).find('.date').text(date);
    }
    // 本月
    for (date=1; date<=dateOfLast; index++,date++) {
      $(boxes[index]).attr('id', `db_${month}_${date}`);
      $(boxes[index]).find('.date').text(date);
    }
    // 下月
    var nextMonth = (month+1+11)%12+1;
    for (date=1; index<42; index++,date++) {
      $(boxes[index]).attr('id', `db_${nextMonth}_${date}`);
      $(boxes[index]).addClass('not-this-month');
      $(boxes[index]).find('.date').text(date);
    }
  },

  /**
   * 繪製指定月份的HTML。
   * @param {Date} date - 要選擇的時間
   * @return {boolean} 是否成功選取(ex.選擇的日期不在現在的日曆中，回傳false)
   */
  selectDate: function(date) {
    if( date.getFullYear() != calendar.status.year )
      return false;
    var month = date.getMonth()+1;
    var date = date.getDate();
    var dateBox = $(`#db_${month}_${date}`);
    if (dateBox.length == 0) 
      return false;
    $('.date-box').removeClass('box-today');
    $(dateBox[0]).addClass('box-today');
    calendar.status.selectedDate = date;
    return true;
  }

}

var infoBar = {


}