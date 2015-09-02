function show_timetable_on_modal(semester_id, showNow){
	var result=0 ;
	$.ajax({
		url: "/user/get_courses",
		data:{
			type: "course_table",
			sem_id: semester_id
		},
		dataType: "json",
		success: function(data){
			var result = $.extend(true, [], data);
			var $table = $('<table>').addClass('table table-bordered');
			data.config = {
				deletable: false ,
				selectable: false,
				popover: true,
				downloadable: true,
				semester_id: semester_id
			};     
			$table.CourseTable(data) ;			
	
			$('#global-modal .close').remove();
			if(data.hash_share){
				var $data = $('<div>').addClass('row');
				$data.append($('<div>').addClass('col-md-2').css('margin-top','5px').html(data.semester_name));
			}else
				var $data = $('<div>').addClass('text-center').html(data.semester_name);
			
			showGlobalModal( $data, $table);
					
			setTimeout(function(){ //wait for the modal show
			if(data.hash_share){
				$data.hide();
				$table.CourseTable("renderImg", "upload") ;
				group_share($data, {hash_share: data.hash_share}) ;
				$data.show();      
			}
				return false ;
			}, 500);
		}
	});
	return ;
}