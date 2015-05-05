
;(function($, window, document, undefined) {
	
	'use strict';
	var pluginName = 'CourseTable';
	
	var Table = function(element, options){
		this.$element = $(element);
		this._element = element;
		this._elementId = this._element.id;

		this.cells = [] ;
		//this.course_data = $.extend(true, [], options.courses); //copy data 
		this.config = options.config || {} ;
		
		this._init($.extend(true, [], options.courses));	
	};
	
	Table.defaults = {
		days :['Mon','Tue','Wed','Thu','Fri','Sat'],
  	times : ['M','N','A','B','C','D','X','E','F','G','H','Y','I','J','K','L'],
		real_times : ['6:00 ~ 6:50','7:00 ~ 7:50','8:00 ~ 8:50','9:00 ~ 9:50','10:10 ~ 11:00','11:10 ~ 12:00','12:20 ~ 13:10','13:20 ~ 14:10','14:20 ~ 15:10','15:30 ~ 16:20','16:30 ~ 17:20','17:30 ~ 18:20','18:30 ~ 19:20','19:30 ~ 20:20','20:30 ~ 21:20','21:30 ~ 22:20'],
		selected_class: "schd-grid-selected",
		$cancel_but : $($('<div>').addClass('course-clean').css("display", "none")
									.html($('<i>').addClass('fa fa-times').addClass('clickable-hover'))),	

		cancelButtonFunc: function(args){
			// args.data.xxxxx
			logDebug("callback function is not define.");
		}
	};
	
	Table.prototype = {
		
		getSelectedSlot: function(res){
			//var res = [];
			for(var i=0 ; i<this.cells.length; ++i)
			{
				for(var j=0; j<this.cells[i].length; ++j)
				{
					if(this.cells[i][j].selected)
					{				
						res.push( this.cells[i][j].time );
					}
				}
			}
			
			return res ;
		},
		
		deleteCourse: function(cid){
			var res = this._findCellByCourseId(cid) ;
			for(var i=0, cell; cell=res[i];++i){
				this._clearCell(cell);
			}
		},
		
		addCourses: function(args){
			for(var k=0, course; course=args[k]; k++)
			{		
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
								var bb = Table.defaults.$cancel_but.clone(false).extend({course_id: course.course_id});
								//logDebug(bb);
								bb.click({course_id: course.course_id}, Table.defaults.cancelButtonFunc );
								$cell.append(bb).extend({course_id: course.course_id});
								if(this.config.popover)
									$cell.popover({ 
										content:"教室:"+course.room,
										placement:"auto",
										trigger : "hover",
										container :"body"
									});
							//	logDebug($cell);
								$cell.mouseover(function(){
									$(this).find('div').show();					
								}).mouseleave(function(){
									$(this).find('div').hide();
								});
								$cell.selectable = false ;
							}
							
						}
					}
				}	
			}
			return ;
		},

		_init: function(courses){
			this.$element.empty();
		  for(var i=0; i< Table.defaults.days.length;++i)
		  	this.cells.push([]);
			
			// self-define cancel buton callback
			if(this.config.cancelButtonFunc)
				Table.defaults.cancelButtonFunc =  this.config.cancelButtonFunc;
				Table.defaults.popoover |= this.config.popover ;
			
		  this._build();
			this.addCourses(courses);
			this._setSelectFunc();
		},
		
		_build: function(){

			var row = '<tr><th class=""></th>';
			
			for(var i = 0, t; t=Table.defaults.days[i]; i++)					
				row += '<th class="col-md-2"><p class="text-center">'+t+'</p></th>';			
			this.$element.append(row+'</tr>');
			for (var i = 0, t; t=Table.defaults.times[i]; i++) 
			{
				var $this_tr = $('<tr>').insertAfter(this.$element.find('tr:last'));
				var $last_td = $('<td>').appendTo($this_tr)
					.attr('id','time_'+t)
					.addClass('schedule-grid')
					.html($('<p>').addClass('text-center').html(t)); 
				
				if(Table.defaults.popover)				
					$last_td.popover({
						content: Table.defaults.real_times[i], 
						placement: "auto", 
						trigger : "hover", 
						container: "body"});	
						
				for(var j=Table.defaults.days.length; j>0; --j)
				{
					this.cells[j-1].push($('<td>').insertAfter($last_td)
					.attr('id','day_'+j+'_time_'+t)
					.addClass('pos-relative')
					.extend({
						time: j+Table.defaults.times[i], 
						selectable: true, 
						deletable: this.config.deletable || Table.defaults.deletable,
						selected: false 
					}));
				}
				

			}
			return ;
		},
		_findCellByCourseId: function(c_id){
				var res = [];
				for(var i=0 ; i<this.cells.length; ++i)
				{
					for(var j=0; j<this.cells[i].length; ++j)
					{
						if(this.cells[i][j].course_id==c_id)
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
					if(this.cells[i][j].selectable){
						var $target = this.cells[i][j] ;
						this.cells[i][j].click({cell: $target}, function(args){
							$(this).toggleClass(Table.defaults.selected_class);
							args.data.cell.selected = $(this).hasClass(Table.defaults.selected_class);
						});
					}	
				}
			}
		},
		
		_clearCell(cell){
			cell.empty().removeClass().addClass('pos-relative');
			if(this.config.popover)
				cell.popover('disable');
			cell.selectable = this.config.selectable ;
			if(cell.selectable)
				cell.click({cell: cell}, function(args){
					$(this).toggleClass(Table.defaults.selected_class);
					args.data.cell.selected = $(this).hasClass(Table.defaults.selected_class);
				});
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
		
		return this.each(function() { // 'this' is the target table
			var self = $.data(this, 'plugin_' + pluginName);
			if (typeof options === 'string') {
				if (!self) {
					logError('Not initialized, can not call method : ' + options);
				}
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
		
	};
	
})(jQuery, window, document);