
;(function($, window, document, undefined) {
	
	'use strict';
	var pluginName = 'StatisticsTable';
	
	var _default = {
	  
	  
	} ;
	
	
	var Table = function(element, options){
		this.$element = $(element);
		
		this.course_map = $.extend(true, [], options.course_map);
		this.user_courses = $.extend(true, [], options.user_courses);
		this.user_info = $.extend(true, [], options.user_info);
//		delete options ;
		
		this.data = null ;
		
		// if have 大一上, 大一下, then length = 2
		_default.semester_length = (this.user_info.year_now - this.user_info.year + 1) * 2 - (this.user_info.half_now - 2) ;
		
		
		this._parseMap();
	};
	
	//Table.specReturnMethod = ["checkConflictByTime", "getSelectedSlot", "getAllCourses"] ;
	
	var parseSemesterStr = function(sem_str){
	  var year = parseInt(sem_str);	  
	  var half = sem_str[sem_str.length-1];
	  if(!year || half=="署")
	    return 0 ;
	  half = (half=="上") ? 1 : 2 ;
	  return [year, half]; 
	};
	
	var checkPass = function (pass_score,score){
	  return score=="通過" || score=="修習中" || parseInt(score)>=pass_score
  };
  
  var calSemIdx = function(year, half){
    var dyear = year - this.user_info.year ;
    var dhalf = half - 1 ;
    return dyear*2 + dhalf ;
  };
	
	Table.prototype = {
		
		// create row of a course (the first two td are not created)
		_createOneRow:funciton(cf_course, courses){
		  var $td_ary = [] ;
		  var pass = false; 
		  var note = "" ;
		  for(var i=0; i<_default.semester_length; ++i)
		    $td_ary.push($('<td>')) ;
		    
		  for(var i=0, c ; c=courses[i]; ++i)
		  {
		    var sem_info = parseSemesterStr(c.sem_name);
		    pass |= checkPass(c.pass_score, c.score);
		    note += c.memo+" ";
		    if(sem_info==0)
		      c.idx = -1 ;
		    else{
		      c.idx = calSemIdx(sem_info[0], sem_info[1]);
		      td.ary[c.idx].html(c.score);
		    }  
		  }
		  var $row = $('<tr>');
		  for(var i=0; i<_default.semester_length; ++i)
		    $row.append($td_ary[i]);
		  $row.append( $('<td>').html(cf_course.credit) )
		  .append( $('<td>').html( ((pass) ? cf_course.credit : "" ) ) )
		  .append( $('<td>').html(note) );
		  
		  return $row ;  
		},
		
		// create rows of a bottom cf
		_createRows: function(cf, courses, recordAll){
		  var $rows = [] ;
		  for(var i=0, cf_course; cf_course = cf.courses[i]; ++i)
		  {
		    var matchs = $.grep(courses,  function(e){ return e.id == cf_course.id; }) ;
		    if( matchs>0 || recordAll)
		      $rows.push(this._createOneRow(cf_course, matchs));
		  }
		  for(var i=0, cf_cg; cf_cg = cf.course_groups[i]; ++i)
		  {
		    var matchs = [] ;
		    for(var j=0, cg_course; cg_course=cf_cg.courses[j]; ++j)	    
		      matchs = matchs.concat( $.grep(courses,  function(e){ return e.id == cg_course.id; }) );
		    if( matchs>0 || recordAll)
		      $rows.push(this._createOneRow(cf_course, matchs));
		  }
		  return $rows ;
		},
		
		_parseMap: function(){
		  for(var i=0, cf; cf = this.course_map[i];++i)
		  {
		    switch(cf.cf_type)//travel to the end of tree
        {
          case 1://必修
          case 2://x選y
            var matchs = this.user_courses.filter(function(x) { return (x.cf_id==cf.id); });
            var res = this._createRows(cf, matchs, (cf.cf_type==1));
            
            break;
          case 3://領域
            break; 
          case 4://群組
            break ;
        }  
		  }
		
		}
			
	}  
	
	var logError = function(message) {
		if(window.console) {
				window.console.error(message);
		}
  };
	var logDebug = function(message) {
		if(window.console) {
				window.console.debug(message);
		}
	};
	
	$.fn[pluginName] = function(options, args) {
		//here are not return self
		if(typeof options === 'string' 
		   && ($.inArray(options, Table.specReturnMethod)!=-1) )
		{		
			var self ;
			this.each(function() { self = $.data(this, 'plugin_' + pluginName);});
			if (!self){
				logError('Not initialized, can not call method : ' + options);
				return ;
			}else
				return self[options].call(self, args) ;	
		}
		else
		{					
			return this.each(function() { // 'this' is the target table. It'll return itself.
				var self = $.data(this, 'plugin_' + pluginName);
				if (typeof options === 'string') {
					//block undefine method
					if (!self) {
						logError('Not initialized, can not call method : ' + options);
					}
					//block using private method
					else if (!$.isFunction(self[options]) || options.charAt(0) === '_') {
						logError('No such method : ' + options);
					}
					else {
						self[options].call(self, args) ;// .apply 會自動拆掉一層 []
					}
				}
				else {
					if (!self) {
						$.data(this, 'plugin_' + pluginName, new Table(this, $.extend(true, {}, options)));
					}
					else {
						self._init(options);
					}
				}
			});
		}
	};
	
})(jQuery, window, document);