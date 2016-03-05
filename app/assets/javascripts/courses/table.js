/*
 * app/assets/javascript/courses/table.js
 *
 * Copyright (C) 2016 NCTU+
 * 
 * Course timetable template for course simulation, course share, personal table. 
 *  
 * Updated at 2016/2/14
 */

/* Library options:
 * 	deletable(T/F): enable the delete icon for the cell that has course
 *	selectable(T/F): enable the empty cell to be selected
 *	downloadable(T/F): enable a download icon on left top td cell (This option will conflict with collapsible option. Priority: collapsible > downloadable)
 *	collapsible(T/F): enable a expand icon on left top td cell that is used for show/hide the hidden row (see hideEmpty option)
 *  semester_id(integer): for uploading the image of the timetable. If font end do upload the image, you should provide it.
 *	popover(T/F): enable popover for the cell that has course
 *	hideEmpty(T/F): hide the row that do not have course (only hide time slots "M N I J K L" )
 *	
 *  Note that false value (empty hash) will be applied when no config options are assigned at initialization.	
 *
 * Functions:
 *  getAllCourses(O/hash): output all course data recorded in the library
 *  getSelectedSlot(O/string array):　output all the selected cells by specified time tag (ex. 1A, 4G)
 *  checkConflictByTime(I/string O/TF): check if a giving time slot(1A, 3G) already has course.
 *  deleteCourse(I/integer): delete all the recorded courses that have the same course_detail_id(Input)
 *  addCourses(I/hash array): add courses to target td cell (need to self-check conflict)
 *  renderImg(I/string): generate table image and output in different format according to flag
 *    flag "window": output image with new web tag; flag "url": output with image file url; flag "upload": output to server
 *  adjust_row:  TODO
 *  
 *
 * Internal issues:
 * 1. The td cell is not fix after add/deleting course to the table. The reason is the style position relaitve.
 *		But the position relative is required for the cross icon(position absolute) of deleting course. 
 * 
 */
	
	
//= require courses/html2canvas
;(function($, window, document, undefined) {
	
  'use strict';
	var pluginName = 'CourseTable';

	var Table = function(element, options){

  this.$element = $(element);
  this.cells = [] ;
  this.courses = [] ;
  this.config = options.config || {} ;
  // self-define cancel buton callback
  if(this.config.cancelButtonFunc)
    Table.defaults.cancelButtonFunc =  this.config.cancelButtonFunc;
          
  this._init(options.courses);			
  this.collape_toggle = (typeof(this.config.hideEmpty)=="undefined") ? false : this.config.hideEmpty ;
  this.adjust_row();
	};
	
	Table.specReturnMethod = ["checkConflictByTime", "getSelectedSlot", "getAllCourses"] ;
	
	Table.defaults = {
		days :['Mon','Tue','Wed','Thu','Fri','Sat'],
		daysInCh :['一','二','三','四','五','六','日'],
		times : ['M','N','A','B','C','D','X','E','F','G','H','Y','I','J','K','L'],
		real_times : ['6:00 ~ 6:50','7:00 ~ 7:50','8:00 ~ 8:50','9:00 ~ 9:50','10:10 ~ 11:00','11:10 ~ 12:00','12:20 ~ 13:10','13:20 ~ 14:10','14:20 ~ 15:10','15:30 ~ 16:20','16:30 ~ 17:20','17:30 ~ 18:20','18:30 ~ 19:20','19:30 ~ 20:20','20:30 ~ 21:20','21:30 ~ 22:20'],
		selected_class: "schd-grid-selected",
		conflict_class: "course-conflict",
		$cancel_but : $($('<div>').addClass('course-clean').css("display", "none")
					.html($('<i>').addClass('fa fa-times').addClass('clickable-hover'))),			
		cancelButtonFunc: function(args){
			logDebug("Callback function is not defined.");
		}
	};
	
	Table.prototype = {
		
		_generateDownloadButton: function(sem_id){
		  var $group = $('<div>').addClass('btn-group');
		  
		  var $button = $('<button>').addClass('btn btn-circle btn-success dropdown-toggle')
		                .attr('data-toggle', 'dropdown').attr('aria-expanded', false);
		  var $icon = $('<i>').addClass('fa fa-download');
		  $button.html($icon);
		  
		  var $lists = $('<lu>').addClass('dropdown-menu').attr('role', 'menu');  
	    var $excel_link = $('<a>').attr('href', '/courses/export_timetable.xls?sem_id='+sem_id).html('Excel');
		  var $image_link = $('<a>').attr('href', '#').html('Image');
		  
			var $temp = this.$element		;
		  $lists.html($('<li>').html($excel_link))
		    .append($('<li>').html($image_link).click({"element": $temp}, function(event){ 
						event.data.element.CourseTable('renderImg', "window");
				}));
		  
		  $group.html($button).append($lists) ;
		  return $group ;
		},
		
		_generateCollapseButton: function(){
		  var $icon = $("<i>").addClass("fa fa-bars clickable-hover").css("margin-left", "2px")
				.attr("title","縮放課表").click(function(){
					this.collape_toggle = ~this.collape_toggle ;
					this.adjust_row(this.collape_toggle);
					
				}.bind(this));
		                
		  return $icon ;
		},
		
		_dataURItoBlob: function(dataURI){
			var byteString;
			if (dataURI.split(',')[0].indexOf('base64') >= 0)
					byteString = atob(dataURI.split(',')[1]);
			else
					byteString = unescape(dataURI.split(',')[1]);

			// separate out the mime component
			var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];

			// write the bytes of the string to a typed array
			var ia = new Uint8Array(byteString.length);
			for (var i = 0; i < byteString.length; i++) {
					ia[i] = byteString.charCodeAt(i);
			}

			return new Blob([ia], {type:mimeString});
  	},
		
		renderImg: function(flag){
			
			var _this = this ;	
     // var $global_modal_header = $('#global-modal .modal-header'); 
			
			// hide the item that we don't want to see in the picture	
			_this.$element.find('.btn-group').hide() ;	
		
		  html2canvas( _this.$element.get(0), {
        height: 1500 ,
        onrendered: function(canvas) {
          //recover the hidden items
					_this.$element.find('.btn-group').show();

          var dataUrl = canvas.toDataURL("image/png");
					if (flag=="window"){
						window.open(dataUrl);
						return ;
					}else if(flag=="url"){
					  return dataUrl ;
					}else if(flag=="upload"){  
						var blob = _this._dataURItoBlob(dataUrl);
						//console.log("filesize: "+blob.size);
						var fd = new FormData();
						fd.append("image", blob);
						fd.append("semester_id", _this.config.semester_id);	
						fd.append("type", "upload_share_image");			
						$.ajax({
							type: "post",
              url: "/user/update",
              data: fd,
							cache:false,
							contentType: false,
							processData: false,
							success: function(){console.log("good");},
							error: function(){console.log("upload img fails");}
						});
					}else{ // default
            window.open(dataUrl);
						return ;
          }        
        }
      });
			
      return;
		},
		
		checkConflictByTime: function(args){
			var times = args.time ;
			if(!times) return false ;
		//	logDebug(times);
			var conflict = false ;
			var timearr = times.match(/[0-9][A-Z]+/g);
			for(var i=0,slot; slot=timearr[i]; ++i)
			{
					var day = slot[0];
					
					for(var j=1,time; time=slot[j];++j)
					{
						var idx_y = $.inArray(time,Table.defaults.times) ;
						//logDebug(day+time);						
						if(idx_y>=0)
						{
							var idx_x = day-1 ;
							var $cell = this.cells[idx_x][idx_y];
							if($cell.course && $cell.course.cd_id)
							{
								conflict = true ;
								$cell.addClass(Table.defaults.conflict_class).removeClass(Table.defaults.conflict_class, 3500);
							}
						}	
					}
			}		
			if(conflict) 
				toastr['error']("衝堂囉!");
			return conflict ;
			
		},
		
		getAllCourses: function(){
		  return this.courses ;
		},
		
		//get the time slot that are selected.(1A, 3D, 4G ...)
		getSelectedSlot: function(){
		  var result = [] ;
			for(var i=0 ; i<this.cells.length; ++i)
			{
				for(var j=0; j<this.cells[i].length; ++j)
				{
					if(this.cells[i][j].selected)
					{				
						result.push( this.cells[i][j].time );
					}
				}
			}
			
			return result ;
		},
		
		deleteCourse: function(cd_id){
			var res = this._findCellByCourseDetailId(cd_id) ;
			if(res.length==0)
			{
			  logError("No such course in the object record");
			  return ;
			}
			for(var i=0, $cell; $cell=res[i];++i){
				this._clearCell($cell);
			}
			this.adjust_row(this.collape_toggle);
			return ;
		},
		
		addCourses: function(args){
		//	logDebug(this.config.popover);
		 
			for(var k=0, course; course=args[k]; k++)
			{		
			  this.courses.push($.extend(true, {}, course));//record course
				if(!course.time) continue ;//藝文欣賞
				var timearr = course.time.match(/[0-9][A-Z]+/g);
				//logDebug(timearr);
				for(var i=0,slot;slot=timearr[i];++i)
				{
					var day = slot[0];
					for(var j=1,time; time=slot[j];++j)
					{
						var idx_y = $.inArray(time,Table.defaults.times) ;
						if(idx_y>=0)
						{
							var idx_x = day-1 ;
							var $cell = this.cells[idx_x][idx_y];
							
							$cell.html(course.name).addClass(course.class).selectable = false;
							
							if(this.config.deletable)
							{
								var $button = Table.defaults.$cancel_but.clone(false);
								$button.click({cd_id: course.cd_id}, Table.defaults.cancelButtonFunc );
								//only deletable cell need to record which course (point to this.course element)
								$cell.append($button).extend({course: course});							 
							//	logDebug($cell);
								$cell.mouseover(function(){
									$(this).find('div').show();					
								}).mouseleave(function(){
									$(this).find('div').hide();
								});
								//$cell.selectable = false ;
								this._setCellSelectFunc($cell);
							}
							if(this.config.popover)
							{
									$cell.popover({ 
										content:"教室:"+course.room,
										placement:"auto",
										trigger : "hover",
										container :"body"
									});
							}	
							if(this.config.click_redirect) // This will conflict with cell selectable
							{
							  $cell.addClass("clickable-hover");
							  $cell.click({cd_id: course.cd_id}, function(args){
							    window.open("http://"+window.location.host+"/courses/"+args.data.cd_id);
							    return true ;
							  });
							}
						}
					}
				}	
			}
			this.adjust_row(this.collape_toggle);
			return ;
		},

		adjust_row: function(){
			var fix_row = [0,3,4,5,6,7,8,9,10,11]; // header, A, B, C, D, X, E, F, G, H
			$("#"+this.$element.attr("id")+" tr").show();
			if(!this.collape_toggle)		
				return ;	
			this.$element.find("tr").each(function(tr_idx){   
				var $tr = $(this);
				//console.log($.inArray(tr_idx, fix_row));
				if($.inArray(tr_idx, fix_row)<0) //skip weekend header & default class time
				{
					var flag = true ;
					$(this).children("td").each(function(td_idx){
						var $td = $(this);
						if(td_idx>0) // skip class time slot 
						{
							if(!$td.is(':empty')) {
								flag = false ;											
							}
						}
					});
					if(flag) $(this).hide();
				}
			});
		},
		
		_init: function(courses){
			this.$element.empty();
		  for(var i=0; i< Table.defaults.days.length;++i)
		  	this.cells.push([]);
			
			
		  this._build();
			this.addCourses(courses);
		  this._setSelectFunc();
		},
		
		_build: function(){
			var days = Table.defaults.days ;
			
			var $leftupth = $('<th>') ;
	/* the left top cell icon */		
		// downloadable(first prioiry)
			if(this.config.downloadable)
					$leftupth.html(this._generateDownloadButton(this.config.semester_id));
		// collapsible 
			if(this.config.collapsible)
					$leftupth.html(this._generateCollapseButton());
				
			var $row = $('<tr>').append($leftupth);
			for(var i = 0, t; t=days[i]; i++){
				$row.find('th:last').after($('<th>').addClass('col-md-2')
					.html($('<p>').addClass('text-center').html(t)));
			}	
			this.$element.append($row);			

			for (var i = 0, t; t=Table.defaults.times[i]; i++) 
			{
				var $this_tr = $('<tr>').insertAfter(this.$element.find('tr:last'));
				var $last_td = $('<td>').appendTo($this_tr)
					.attr('id','time_'+t)
					.addClass('schedule-grid')
					.html($('<p>').addClass('text-center').html(t)); 
				
				if(this.config.popover)				
					$last_td.popover({
						content: Table.defaults.real_times[i], 
						placement: "auto", 
						trigger : "hover", 
						container: "body"});	
						
				for(var j=days.length; j>0; --j)
				{
					this.cells[j-1].push($('<td>').insertAfter($last_td)
					//.attr('id','day_'+j+'_time_'+t)
					.addClass('pos-relative')
					.extend({
						time: j+Table.defaults.times[i], 
						selectable: this.config.selectable || false, 
						deletable: this.config.deletable || false,
						selected: false 
					}));
				}
				
			

			}
			return ;
		},
		_findCellByCourseDetailId: function(cd_id){
				var res = [];
				for(var i=0 ; i<this.cells.length; ++i)
				{
					for(var j=0; j<this.cells[i].length; ++j)
					{
					  var $cell = this.cells[i][j] ;
						if($cell.course && $cell.course.cd_id==cd_id)
							res.push( this.cells[i][j] );
					}
				}
				return res ;
		},
		
		_setSelectFunc: function(){
			for(var i=0 ; i<this.cells.length; ++i)
			{
				for(var j=0; j<this.cells[i].length; ++j)
				{
					var $cell = this.cells[i][j] ;
					this._setCellSelectFunc($cell);
				}
			}
		},
		
		_setCellSelectFunc: function($cell){
			
			if($cell.selectable){		
				$cell.click({cell: $cell}, function(args){
					$(this).toggleClass(Table.defaults.selected_class);
					args.data.cell.selected = $(this).hasClass(Table.defaults.selected_class);
				});
			}else{
				$cell.selected = false ;
				$cell.removeClass(Table.defaults.selected_class);
				if(!this.config.click_redirect)// avoid conflict
				  $cell.unbind('click');
			}	
		},
		
		_clearCell: function($cell){
		  this.courses.splice( $.inArray($cell.course, this.courses), 1 );
			$cell.empty().removeClass().addClass('pos-relative').course=undefined;
			if(this.config.popover)
				$cell.popover('disable');
			$cell.selectable = this.config.selectable ;
			this._setCellSelectFunc($cell);
			return ;
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
			return this.each(function() { // 'this' is the target table. It returns itself.
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
