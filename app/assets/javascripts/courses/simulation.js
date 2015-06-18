//= require page-tour/jquery.cookie
//= require page-tour/modernizr.mq
//= require page-tour/jquery.joyride-2.1

function loadCourseTable(semester_id, selectable){
	$.getJSON("/user/get_courses?type=course_table&sem_id="+semester_id,function(data){
		//console.log(data);
		data.config = {
			deletable: true ,
			selectable: true,
			popover: true,
			cancelButtonFunc: function(arg){
				var cd_id = arg.data.cd_id;
				save_course(cd_id,'delete','load_course_table');
			}
		};
		$('#schedule_table').CourseTable(data);	
	});
}

function showHasSelected(){
	$.getJSON("/user/get_courses?type=simulation",function(data){
		//console.log(data);
		$(".scrollable").html(tmpl("search_result", data));
	});
}