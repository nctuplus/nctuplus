
;(function($, window, document, undefined) {
	
	'use strict';
	var pluginName = 'StatisticsTable';
	
	var _default = {
	  degrees : ["一", "二" ,"三" , "四", "五"],
	  gra_name : "大",
	  commons: ["必修", "外語", "通識"]
	} ;
	
	
	var Table = function(element, options){
		this.$element = $(element);
		
		this.course_map = $.extend(true, [], options.course_map);
		this.user_courses = $.extend(true, [], options.user_courses);
		this.user_info = $.extend(true, [], options.user_info);
	//	logDebug(this.user_info);
	//	logDebug(this.user_courses);
//		delete options ;
		
		this.data = null ;
		
		// The number of th cells for the user
		_default.semester_length = (this.user_info.year_now - this.user_info.year) * 2 + this.user_info.half_now  ;
		// The prefix of th html ex. "研"一上, ("大")一上 
		_default.gra_name = (this.user_info.degree==2) ? "研" : "" ;
		
		this._addHeader('ㄧ. 本系所專業科目', '#A9F5BC');
		this._parseMap();
		this._parseExtrasolar();
		this._parseCommon();
	};
	
	//Table.specReturnMethod = ["checkConflictByTime", "getSelectedSlot", "getAllCourses"] ;
	
	var parseSemesterStr = function(sem_str){
	  var year = parseInt(sem_str);	  
	  var half = sem_str[sem_str.length-1];
	  if(isNaN(year) || half=="署")
	    return 0 ;
	  half = (half=="上") ? 1 : 2 ;
	  return [year, half]; 
	};
	
	var checkPass = function (pass_score,score){
	  return score=="通過" || parseInt(score)>=pass_score
  };
  	
  var groupBy = function ( array, f){
    var groups = {};
    array.forEach( function( o )
    {
      var group = JSON.stringify( f(o) );
      groups[group] = groups[group] || [];
      groups[group].push( o );  
    });
    return Object.keys(groups).map( function( group )
    {
      return groups[group]; 
    });
  };	
  	
	Table.prototype = {
		
		_addHeader: function(text, color_code){
			var col_cnt = _default.semester_length+6 ;
			var $hrow = $('<tr>').html($('<td>').attr('colspan', col_cnt)
			.attr('bgcolor', color_code).html($('<p>').html(text)));
			var $srow = $('<tr>');
			$srow.append($('<td>').attr('colspan', 2));
			$srow.append($('<td>').html($('<p>').html('科目名稱')));
			for(var i=0; i<_default.semester_length; ++i)
			{	
					var half_name = (i%2==0) ? "上" : "下" ;
					$srow.append($('<td>').html(_default.gra_name+_default.degrees[Math.floor(i/2)]+half_name));	
			}
			$srow.append($('<td>').html('應修'));
			$srow.append($('<td>').html('實得'));
			$srow.append($('<td>').html($('<p>').html('備註')));
			
			this.$element.append($hrow).append($srow);
			return ;
		},
		
		// create row of a course (the first two td are not created)
		_calSemIdx: function(year, half){
			var dyear = year - this.user_info.year ;
			var dhalf = half - 1 ;
			return dyear*2 + dhalf ;
		},
		
		_createOneRow : function(cf_course, courses){
		  var $td_ary = [] ;
		  var pass = false; 
		  var note = "" ;
			
		  for(var i=0; i< _default.semester_length; ++i)
		    $td_ary.push($('<td>')) ;
			
		    
		  for(var i=0, c ; c=courses[i]; ++i)
		  {
		    var sem_info = parseSemesterStr(c.sem_name);
				//logDebug(sem_info);
				if(c.score=="")//舊資料導致，需要請user重新import
				  c.score='<font color="red">缺(請重新匯入)</font>'; 
				
		    pass |= checkPass(c.pass_score, c.score);
		    note += c.memo+" ";
		    if(sem_info==0)
		      c.idx = -1 ;
		    else{
		      c.idx = this._calSemIdx(sem_info[0], sem_info[1]);		
		      $td_ary[c.idx].html(c.score);
		    }  
		  }
			$td_ary.unshift($('<td>').html(cf_course.name));
		  var $row = $('<tr>');
		  for(var i=0; i<$td_ary.length; ++i)
		    $row.append($td_ary[i]);
		  $row.append( $('<td>').html(cf_course.credit) ).append( $('<td>').html( ((pass) ? cf_course.credit : 0 ) ) ).append( $('<td>').html(note) );
		  
		  return $row ;  
		},
		
		// create rows of a bottom cf
		_createRows: function(cf, courses, recordAll){
		  var $rows = [] ;
			var row_cnt= 0;
		  for(var i=0, cf_course; cf_course = cf.courses[i]; ++i)
		  {
		    var matchs = $.grep(courses,  function(e){ return e.cos_id == cf_course.id; }) ;
				
		    if( matchs.length>0 || recordAll){
					row_cnt +=1;
		      $rows.push(this._createOneRow(cf_course, matchs));
				}
			}
		  for(var i=0, cf_cg; cf_cg = cf.course_groups[i]; ++i)
		  {
		    var matchs = [] ;
		    for(var j=0, cg_course; cg_course=cf_cg.courses[j]; ++j)
		      matchs = matchs.concat( $.grep(courses, function(e){ return e.cos_id == cg_course.id; }) );    
				if( matchs.length>0 || recordAll){
					row_cnt+=1;
		      $rows.push(this._createOneRow(cf_cg.lead_course, matchs));
				}	
		  }
		  return {data: $rows, rowspan: row_cnt} ;
		},
		
		_parseCommon: function(){
		  var matchs = $.grep(this.user_courses,
		    function(e){ 
		      return (e.cf_id==0 && $.inArray(e.cos_type, _default.commons)!=-1); 
		    }) ;
	//	  logDebug(matchs);
		  if(matchs.length>0)
		  {
		    this._addHeader('三. 校訂共同科目', '#F4FA58');
		    matchs = groupBy(matchs, function(item){ return [item.cd_id] ;});
		    matchs = matchs.sort(function(a, b){ return (a[0].name > b[0].name);});
	//	    logDebug(matchs);  
		    for(var i=0, courses; courses = matchs[i]; ++i)
		    {
		      var $row = this._createOneRow(courses[0], courses);
		      $row.find('td:first').before($('<td>').attr('colspan', 2));
		      this.$element.append($row);
		    }
		  }
		},
		
		_parseExtrasolar: function(){
		  var matchs = $.grep(this.user_courses,
		    function(e){ 
		      return (e.cf_id==0 && e.cos_type=="選修"); 
		    }) ;
		  
		  if(matchs.length>0)
		  {
		    this._addHeader('二. 其他選修科目(外系所選修)', '#FAAC58');
		    matchs = groupBy(matchs, function(item){ return [item.cd_id] ;});
		    //logDebug(matchs);
				matchs = matchs.sort(function(a, b){ return (a[0].name > b[0].name);});
		    logDebug(matchs);  
				for(var i=0, courses; courses = matchs[i]; ++i)
		    {
					//logDebug(courses);
		      var $row = this._createOneRow(courses[0], courses);
		      $row.find('td:first').before($('<td>').attr('colspan', 2));
		      this.$element.append($row);
		    }
		  }
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
						if(res.rowspan>0)
						{
							var $cf_info = $('<td>').attr("rowspan", res.rowspan).attr("colspan", 2).html(cf.cf_name);
							res.data[0].find('td:first').before($cf_info);
							this.$element.append(res.data);
						}
            break;
          case 3://領域
            var cf_rowspan = 0 ;
            var $all_first_tr = null ;
            for(var j=0, sub_cf; sub_cf=cf.child_cf[j]; j++)//子領域
				    {
				      var sub_cf_rowspan = 0 ;		
				      var $sub_cf_first_tr = null ;      
				      for(var k=0, bottom_cf; bottom_cf=sub_cf.child_cf[k];++k)//必修or選修
					    {
					      var matchs = this.user_courses.filter(function(x) { return (x.cf_id==bottom_cf.id); });
                var res = this._createRows(bottom_cf, matchs, false);
                if(res.rowspan>0)
                {
                  this.$element.append(res.data);
                  if(!$sub_cf_first_tr)
                    $sub_cf_first_tr = res.data[0] ;
                  if(!$all_first_tr)  
                    $all_first_tr = res.data[0] ;
                  sub_cf_rowspan += res.rowspan ;  
                }        
					    }
					    if($sub_cf_first_tr)//塞子領域name
              {
                var $sub_cf_info = $('<td>').attr("rowspan", sub_cf_rowspan).html(sub_cf.cf_name);
                $sub_cf_first_tr.find('td:first').before($sub_cf_info);
              }
					    cf_rowspan += sub_cf_rowspan ;
				    }
				    if($all_first_tr)//塞領域name
            {
              var $cf_info = $('<td>').attr("rowspan", cf_rowspan).html(cf.cf_name);
              $all_first_tr.find('td:first').before($cf_info);
            }
            break; 
          case 4://群組
            var rowspan = 0 ;
            var $first_tr = null ;
            for(var j=0, bottom_cf; bottom_cf=cf.child_cf[j]; j++)
            {
              var matchs = this.user_courses.filter(function(x) { return (x.cf_id==bottom_cf.id); });
              var res = this._createRows(bottom_cf, matchs, (bottom_cf.cf_type==1));
              if(res.rowspan>0)
              {
                var $cf_info = $('<td>').attr("rowspan", res.rowspan).html(bottom_cf.cf_name);
                res.data[0].find('td:first').before($cf_info);
                this.$element.append(res.data);
                if(!$first_tr)
                  $first_tr = res.data[0] ;
                rowspan += res.rowspan ;  
              }        
            }
            if($first_tr)
            {
              var $cf_info = $('<td>').attr("rowspan", rowspan).html(cf.cf_name);
              $first_tr.find('td:first').before($cf_info);
            }
            break ;
        }  
		  }
		
		}
			
	}  ;
	
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