function head_binding(allow, cd_id){
	$('.edit-head').click(function(){
		
		if(!allow)
			toastr["warning"]("請先登入謝謝");
		else if($(this).hasClass('ing')){	
			$(this).html('編輯');
			reset_head();
		}else{
			$(this).html('收回');
			$('.exam').click(function(){
				$(this).toggleClass('btn-default btn-danger').toggleClass('noted');	
			});
			$('.hw').click(function(){
				$(this).toggleClass('btn-default btn-warning').toggleClass('noted');		
			});		
			var select_data = '<select class="rollcall-select">' ;
			select_data += '<option value="1">每堂必點</option>';
			select_data += '<option value="2">經常抽點</option>';
			select_data += '<option value="3">偶爾抽點</option>';
			select_data += '<option value="4">不點名</option>';
			select_data += '</select>';
			$('.rollcall').hide().after(select_data);
			var select_val = ($('.rollcall').attr('id')==0) ? 1 : $('.rollcall').attr('id') ;
		//	console.log(select_val);
			$('.rollcall-select').val(select_val).after('<button class="btn btn-success pull-right head-submit">送出</button>') ;
			$('.head-submit').click(function(){				
				$('.edit-head').html('編輯').toggleClass('ing');			
				
				$('.head-submit').remove();
				$('.exam, .hw').unbind( "click" );
				var hw_data = 0 ;
				var exam_data = 0 ;
				var rollcall = $('.rollcall-select').val() ;
				$('.rollcall-select').remove();
				$('.hw').each(function(index){// start from 0
					if($(this).hasClass('btn-warning'))
						hw_data += Math.pow(2,index);
				});					
				$('.exam').each(function(index){// start from 0
					if($(this).hasClass('btn-danger'))
						exam_data += Math.pow(2,index);
				});
				$('.hw, .exam').removeClass('noted');
				$.ajax({
					type: "POST",
					url: "/course_content/course_action" ,
					data:{
						type: "content-head",
						cd_id: cd_id,
						hw_data: hw_data,
						exam_data: exam_data,
						rollcall: rollcall,
					},	
					success: function(data){
						toastr["success"]("UPDATE SUCCESSFUL");
						$('.rollcall').removeClass().addClass('label rollcall label-'+data.rollcall_info.color).html(data.rollcall_info.name).show();
						$('.rollcall').attr('id',data.rollcall_info.id);
					},	
					error: function(){
						toastr["error"]("UPDATE FAIL");
						reset_head();
					}
				});	
							
				$('.hw, .exam').removeClass('noted');
			});
		}
		$(this).toggleClass('ing');
	});
	return ;
}

function lists_binding(allow, cd_id){
	if($('.content-list-table tr').length>1)
		$('.no-data').hide();
	$('.edit-lists').click(function(){
		if(!allow){
			toastr["warning"]("請先登入謝謝");
			return false ;
		}else if($(this).hasClass('ing')){
			if($('.content-list-table tr').length==1)	
				$('.no-data').show();
			$(this).html('編輯');
		//	$('.edit-options').hide();		
		}else{
			$('.no-data').hide();
			$(this).html('收回');
		//	$('.edit-options').show();
		}
		$(this).toggleClass('ing');
		$('.edit-options, .new-list, .rank').toggle();	
	});
	binding_option(allow, cd_id);// binding list edit/delete
	
}
function binding_option(allow, cd_id){
	if(!allow){
		$(".rank-edit").removeClass('clickable-hover');
		return false ;
	}	
	_bind_edit_delete_rank($(".list-edit"), $(".list-delete"), $(".rank-edit"));
	$('.new-list-submit').click(function(){
		if(!confirm("確定資料無誤嗎?"))
			return false;
		var this_tr = $(this).parents('tr');
		var list_type = this_tr.children('td');
		var list_content = this_tr.children('td').eq(1).children('span');
		if(list_content.children().val().length == 0){
			toastr["warning"]("請勿留白");
			return false ;
		}
		$.ajax({
			type: "POST",
			url: "/course_content/course_action" ,
			data:{
				type: "content-list-new",
				cd_id: cd_id,
				list_type: list_type.children('select').val(),
				list_content: list_content.children().val()
			},	
			success: function(data){
				toastr["success"]("UPDATE SUCCESSFUL");
			//	console.log(data);
				data["new"] = true ;
				var length = $('.content-list-table tr').length-1 ;//tr excluding new-list
				var new_tr = null ;
				if(length==0){
					$('.content-list-table tr').eq(0).before(tmpl("content-list-cell", data));  //make_new_list(data)
					new_tr = $('.content-list-table tr').eq(0);
				}else{
					$('.content-list-table tr').eq(length-1).after(tmpl("content-list-cell", data));
					new_tr = $('.content-list-table tr').eq(length);
				}
				var new_tr_td_span = new_tr.children('td').eq(1).children('span').eq(3).children('div');
				var new_rank_span = new_tr.children('td').eq(1).children('span').eq(2);
				_bind_edit_delete_rank(new_tr_td_span.eq(0), new_tr_td_span.eq(1),new_rank_span.children('i') );
				//reset new-list
				list_type.children('select').val(1);
				list_content.children().val('');
				sortRowByDatetime($('.content-list-table'), 'DESC');
			},	
			error: function(){
				alert('Something error happen. Please reload :(((');
				toastr["error"]("UPDATE FAIL");					
			}
		});	
		
	});
	
	return false ;

}

function _bind_edit_delete_rank(b_edit, b_delete, b_rank){
	b_edit.click(function(){
		$(this).parents('tr').children('td').each(function(index){
			if(index==0){
				var id = $(this).attr('id');
				var select_data = '<select class="form-control">' ;
				select_data += '<option value="1">考試</option>';
				select_data += '<option value="2">作業</option>';
				select_data += '<option value="3">上課</option>';
				select_data += '<option value="4">其他</option>';
				select_data += '</select>';
				$(this).html(select_data);
				$(this).children('select').val(id);

			}else if(index==1){
				var target = $(this).children('span').first();
				var button_group = $(this).children('span').last();
				target.html('<input type="text" class="form-control" maxlength="32" value="'+target.html()+'">');
				button_group.children('div').hide();
				button_group.append('<div class="btn btn-success btn-circle edit-submit"><i class="fa fa-check"></i></div>');

				button_group.children().last().click(function(){
					
					if(!confirm('確定資料無誤嗎?'))
						return false;
					var data_tr = $(this).parents('tr') ;
					var list_type = data_tr.children('td').first();
					var list_content = data_tr.children('td').eq(1).children('span');
					var this_div = $(this);
					if(list_content.children('input').val().length == 0){
						toastr["warning"]("請勿留白");
						return false ;
					}
					$.ajax({
						type: "POST",
						url: "/course_content/course_action" ,
						data:{
							type: "content-list-edit",
							list_id: data_tr.attr('id'),
							list_type: list_type.children('select').val(),
							list_content: list_content.children('input').val()
						},	
						success: function(data){
						//	console.log(data);
							if(data.update)
								toastr["success"]("UPDATE SUCCESSFUL");
							list_type.attr('id',data.content_type.id).html(data.content_type.name);
							list_content.eq(0).html(data.content);//content
							list_content.eq(1).html(data.time+' '+data.user_name);//time
							list_content.eq(1).attr('date', data.time);
								
							if(!data.is_my)
								this_div.parent('span').html('');
							else{
								this_div.parent('span').children().show();
								this_div.remove();
							}
							sortRowByDatetime($('.content-list-table'), 'DESC');
						},	
						error: function(){
							alert('Something error happen. Please reload :(((');
							toastr["error"]("UPDATE FAIL");					
						}
					});			
					
				});
			}		

		});

	});
	b_delete.click(function(){
		if(!confirm("確定要刪除嗎?"))
			return false;
		var this_list = $(this).parents('tr');
		$.ajax({
			type: "POST",
			url: "/course_content/course_action" ,
			data:{
				type: "content-list-delete",
				list_id: this_list.attr('id'),
			},	
			success: function(data){
				toastr["success"]("UPDATE SUCCESSFUL");
				this_list.remove();
			},	
			error: function(){
				alert('Something error happen. Please reload :(((');
				toastr["error"]("UPDATE FAIL");					
			}
		});		
		
	});
	
	b_rank.click(function(){
		var this_i = $(this);
		var voted = $(this).parents('span');
		var rank_type = $(this).attr('id');
		var list_id = $(this).parents('tr').attr('id');
		if(voted.attr('voted')==1){
			toastr["warning"]("你已經投過票了");	
			return false ;
		}
	//	var msg = (rank_type==1) ? "Is it good?" : "Is it bad?" ;
	//	if(!confirm(msg))
	//		return false ;
		
		$.ajax({
			type: "POST",
			url: "/course_content/course_action" ,
			data:{
				type: "content-list-rank",
				list_id: list_id,
				rank_type: rank_type
			},	
			success: function(data){
				toastr["success"]("UPDATE SUCCESSFUL");
				voted.attr('voted', 1);// set voted
				this_i.next().text(' '+(parseInt(this_i.next().text())+1).toString());
			},	
			error: function(){
				alert('Something error happen. Please reload :(((');
				toastr["error"]("UPDATE FAIL");					
			}
		});	
	});
}

function reset_head(){
	$('.exam, .hw').unbind( "click" ).each(function(){
		if($(this).hasClass('noted')){
			if($(this).hasClass('exam'))
				$(this).toggleClass('btn-danger btn-default').removeClass('noted');
			else
				$(this).toggleClass('btn-warning btn-default').removeClass('noted');
	}			
	});
	$('.rollcall').show();
	$('.rollcall-select').remove();
	$('.head-submit').remove();
}

function sortRowByDatetime(table, type){
	//console.log("sorting");
	var sort_option = (type=='ASC') ? true : false ;
	var  $table  = table,   // cache the target table DOM element
        $rows   = $('tr', $table); // cache rows from target table body
        
    $rows.sort(function(a, b) {
    	var keyA = _str2datetime($(a).children('td').eq(1).children('span').eq(1).attr('date'));
        var keyB = _str2datetime($(b).children('td').eq(1).children('span').eq(1).attr('date'));
       	if (sort_option) {
        	return (keyA > keyB) ? 1 : 0;  // A bigger than B, sorting ascending
        } else {
        	return (keyA <= keyB) ? 1 : 0;  // B bigger than A, sorting descending
       	}
   	});
   	$rows.each(function(index, row){
      $table.append(row);                  // append rows after sort
   	});
}

function _str2datetime(dateString){
	var dateParts = dateString.split(' '),
    	timeParts = dateParts[1].split(':'),
    	date;

    dateParts = dateParts[0].split('/');

	date = new Date(dateParts[0], parseInt(dateParts[1], 10) - 1, dateParts[2], timeParts[0], timeParts[1]);
	return date ;
}
///

function comment_binding(cd_id){
	$('.comment-submit').click(function(){
		var comment_type = $('#comment_type');
		var comment_content = $('#comment_content');
		if(comment_content.val().length==0){
			toastr["warning"]("請勿留白");
			return false ;	
		}
		
		$.ajax({
			type: "POST",
			url: "/course_content/course_action" ,
			data:{
				type: "comment-new",
				cd_id: cd_id,
				comment_type: comment_type.val(),
				comment_content: comment_content.val()
			},	
			success: function(data){
				//console.log(data);
				toastr["success"]("UPDATE SUCCESSFUL");
				comment_content.val('');
				if($('.comment-lists tr:last').length >0)
					$('.comment-lists tr:last').after(tmpl("course-comment-cell",data));
				else
					$('.comment-lists').append(tmpl("course-comment-cell",data));	
				$('.no-comment').hide();
			},	
			error: function(){
				alert('Something error happen. Please reload :(((');
				toastr["error"]("UPDATE FAIL");					
			}
		});
	});
}
