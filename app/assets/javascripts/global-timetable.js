function show_timetable_on_modal(semester_id, showNow){
	var result=0 ;
	clearGlobalModalWithLoading();
	$.ajax({
		url: "/user/get_courses",
		data:{
			type: "course_table",
			sem_id: semester_id
		},
		dataType: "json",
		success: function(data){
		//	console.log(data);
			var result = $.extend(true, [], data);
			var $table = $('<table>').addClass('table table-bordered');
			data.config = {
				deletable: false ,
				selectable: false,
				popover: true,
				downloadable: true,
				hideEmpty: true,
				semester_id: semester_id
			};     
			$table.CourseTable(data) ;			

			$select = $('<select>').addClass("form-control") ;
			for(var i=0, sem; sem=data.semesters[i]; ++i){
				$option = $('<option>').attr('value', sem.id).html(sem.name);
				if(semester_id == sem.id) $option.attr("selected", "selected");
				$select.append($option);
			}
			$select.change(function(){
			//	console.log($(this).val());
				show_timetable_on_modal($(this).val(), true);
			});
			
			var $title = $('<div>').addClass('row');
			if(data.hash_share && data.courses.length>0 ){		
				$title.append($('<div>').addClass('col-md-3 col-sm-3 col-xs-3').html($select));		
			}else
				$title.append($('<div>').addClass('col-md-3 col-sm-3 col-xs-3').html($select));
			
			showGlobalModal(1,$title,$table,function(){});
					
			if(data.courses.length>0){		
				setTimeout(function(){ //wait for the modal show
				if(data.hash_share){
				//	$title.hide();
					$table.CourseTable("renderImg", "upload") ;
					group_share($title, {hash_share: data.hash_share}) ;
				//	$title.show();      
				}
					return false ;
				}, 600);
			}
		}
	});
	return ;
}