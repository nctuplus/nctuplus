//
// add-event.js 
//  
// Jobs:
// addEvent, addEventToDate function for tag-bell, tag-cale, tag-info
//
// Js import directive for RoR:
//= require calendar/calendar.js
//= require calendar/event-loader.js


var forAddEvent = {
    

	/**
	 * 傳入event物件繪製出來 
	 * @param {number} index - 這一天第幾個事件(從0開始)  (只用在tag-bell功能)
	 * @param {string} dayCount - 倒數幾天  (只用在tag-bell功能)
	 * @param {string} tagType - 是哪個tag在叫他(bell, cale, info)
	 */
	addEvent: function(event, index, dayCount, tagType) {
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
		}else if( (tagType == 'bell'||tagType == 'cale') && event.MaterialType == 'event'){
		  title = event.Title;
		  eventTime = ' ' + yy + '-' + mn + '-' + dd + ' ' + (hh<10?'0':'')+hh + ':' + (mm<10?'0':'')+mm + ':' + (ss<10?'0':'')+ss ;
		  content = '';
		}else if( (tagType == 'bell'||tagType == 'cale') && event.MaterialType == 'assignment'){
		  title = event.CourseName;
		  hh = event.TimeEnd.getHours(), mm = event.TimeEnd.getMinutes(), ss = event.TimeEnd.getSeconds();
		  yy = event.TimeEnd.getFullYear(), mn = event.TimeEnd.getMonth()+1, dd = event.TimeEnd.getDate();
		  eventTime = '  Deadline  ' + yy + '-' + mn + '-' + dd + '   ' + hh + ':' + mm + ':' + ss;
		  content = event.Title;
		}else{
		  return false;
		}

		var e;
		if(tagType == 'bell'){
			if(index == 0) $(`<div class="title-bar">${dayCount}</div>`).appendTo('.count-down');
			e = $(` <div class="thing">
			                <div class="content"><b>${title}</b><br>
			                <span class="glyphicon glyphicon-time"></span>${eventTime}<br>
			                ${content}</div>
			            </div>`).appendTo('.count-down');

		}else if(tagType == 'cale'){
		    e = $(`<div class="thing-cale"><div class="content"><b>${title}</b><br>
		      			<span class="glyphicon glyphicon-time"></span>${eventTime}<br>
		        		${content}</div></div>`).appendTo('.tag-cale');

		}else if(tagType == 'info'){
		    e = $(`<div class="thing-info"><div class="content border-darkblue"><b>${title}</b><br>
						<span class="glyphicon glyphicon-time"></span>${eventTime}<br>
						${content}</div></div>`).appendTo('.tag-info');

		}else return false;




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



	/**
	* 傳入日期抓該日的event  
	* @param {Date} toDate - 傳入的日期
	* @param {String} dayCount - 倒數幾天  (只用在tag-bell功能)
	* @param {string} tagType - 是哪個tag在叫他(bell, cale, info)
	*/
	addEventToDate: function(toDate, dayCount, tagType) {

		var Nyear = toDate.getFullYear(), Nmonth = toDate.getMonth(), Nd = toDate.getDate();
		var hasEvent = false;


		if(tagType == 'bell' || tagType == 'cale'){
			//直接搜遍所有event 找到符合該日期的event則丟入addEvent()
			var savedEvents = eventLoader.events[Nyear*100+Nmonth+1];
			var index = 0;//記錄這一天有幾個event
			for(var i=0; (savedEvents!==undefined && i<savedEvents.length); i++){
			  var tmp = savedEvents[i];
			  var year = tmp.EventTime.getFullYear(), month = tmp.EventTime.getMonth(), d = tmp.EventTime.getDate();

			  if(Nyear == year && Nmonth == month && Nd == d){
			  	switch(tagType){
			  		case 'bell':
						forAddEvent.addEvent(tmp, index++, dayCount, 'bell');
					break;
			  		case 'cale':
						forAddEvent.addEvent(tmp, 0, 1, 'cale');
					break;
			  	}
			    hasEvent = true;
			  }
			}


		}else if(tagType == 'info'){
			//直接搜遍所有event 找到符合該日期的event則丟入addEvent()
			var savedEvents = eventLoader.events[Nyear*100+Nmonth+1];
			//用時間排序(新到舊)
		    savedEvents.sort( function(a, b){return b.EventTime-a.EventTime} );
		    for(var i=0; (savedEvents!==undefined && i<savedEvents.length); i++){
		      //全部加進去
		      var tmp = savedEvents[i];
		      //加進去前先判斷是否為announcement屬性
		      if(tmp.MaterialType == 'announcement'){
		        forAddEvent.addEvent(tmp, 0, 1, 'info');
		        hasEvent = true;
		      }

		    }

		    //直接搜遍所有上個月event
		    savedEvents = eventLoader.events[Nyear*100+Nmonth];
		    //用時間排序(新到舊)
		    savedEvents.sort( function(a, b){return b.EventTime-a.EventTime} );
		    for(var i=0; (savedEvents!==undefined && i<savedEvents.length); i++){
		      //全部加進去
		      var tmp = savedEvents[i];
		      //加進去前先判斷是否為announcement屬性
		      if(tmp.MaterialType == 'announcement'){
		        forAddEvent.addEvent(tmp, 0, 1, 'info');
		        hasEvent = true;
		      }
		    }


		}


		if(!hasEvent)
			if(tagType=='cale') $(`<div class="thing-cale"><div class="content">(無事件)</div></div>`).appendTo('.tag-cale');
			else if(tagType=='info') $(`<div class="thing-info"><div class="content">(近期並無公告)</div></div>`).appendTo('.tag-info');



	}

}