//= require bootstrap-treeview

function load_treeview(target_id, map_id){
	$.getJSON( "/course_maps/get_course_tree.json?map_id="+map_id, function(res){
		console.log('load course tree success');
		$('#course_tree').treeview({data: res, map_id: map_id});
		if (target_id!=0){
			$('#course_tree').treeview('activateNode', ['cf_id', target_id]);
		}
	});
	return ;
}

function load_group_treeview(target_id, map_id){
	$.getJSON( "/course_maps/get_group_tree.json?map_id="+map_id, function(res){
		console.log('load group tree success');
		$('#group_tree').treeview({data: res, map_id: map_id});
		if (target_id!=0)
			$('#group_tree').treeview('activateNode', ['cg_id', target_id]);
	});
	return ;
}

function load_new_form(data){
	$("#new_form_div").html(tmpl("new-form-format", data));	
	$('.new-form').submit(function(event){ //  rebind
		if($('.new-form #name').val().length==0){
			alert('data not complete');
			return false ;
		}
		$.ajax({
			type: "POST",
  			url: "action_new" ,
  			data: $(this).serialize(),
  			success: function(data){
				load_treeview(data, map_id);
  			}
		});
		return false;
	});
}


function reset_data(){
	// reset new form;
	$('#new_form_div').empty();
	// reset header content
	cg_show_id = null ;cf_show_id = null ;
	$('#header_content_div').empty();
	// reset course list content
	$('#course_content').empty();
	return ;
}



function credit_list_action(id,memo,credit_need,type){
	$.ajax({
		type: "POST",
		dataType:"json",
		url: "/course_maps/credit_action" ,
		data:{
			memo : memo,
			credit_need : credit_need,
			id : id,
			cf_id : $("#cf_id").text(),
			type : type
		},	
		success: function(data){
			genCreditList(data);
			$('#alert-msg').removeClass().addClass('text-color-green').html('更新成功').show().fadeOut(2200);
		
		},	
		error: function(){
			$('#alert-msg').removeClass().addClass('text-color-red').html('更新失敗').show().fadeOut(2200);
		}		
	});
}

function bind_credit_list_button(){
	$("#credit_list .update-credit").click(function(){
		var this_row=$(this).parent().parent();
		var memo_tag=this_row.find(".memo");
		var credit_tag=this_row.find(".credit-need");
		if($(this).hasClass('edit')){
			if(!confirm('要送出嗎？'))
				return false ;
			credit_list_action(this_row.attr("id"),memo_tag.find("input").val(),credit_tag.find("input").val(),"update");
		}else{		
			memo_tag.html('<input type="text" value="'+memo_tag.text()+'" class="form-control">');
			credit_tag.html('<input type="text" value="'+credit_tag.text()+'" class="form-control">');
			$(this).html('<i class="fa fa-check"></i>').switchClass('btn-warning','btn-success');
			$(this).addClass('edit') ;			
		}
		
	});
	$("#credit_list .delete-credit").click(function(){
		var this_row=$(this).parent().parent();
		if(this_row.parent().find(".row").length>1)
		credit_list_action(this_row.attr("id"),"","","delete");
		else
			toastr['info']("最少需有1個學分列!");
	});
}

function create_credit(){
	credit_list_action('',$("#new_memo").val(),$("#new_credit_need").val(),"add");	
}

function bind_header_button(header_node){
	$('#header_content_div .add_credit_list').click(function(){
		if($("#new_credit").length==0){
			var form="<div id='new_credit' class='row'>";
				form+='<div class="col-md-2 memo">';
				form+='<input type="text" id="new_memo" class="form-control" placeholder="說明"></div>';
				form+='<div class="col-md-3">至少學分數</div>';
				form+='<div class="col-md-2">';
				form+='<input type="text" id="new_credit_need" class="form-control"></div>';
				form+='<div class="col-md-3"><button class="btn btn-circle btn-success" onclick="create_credit();"><i class="fa fa-check"></i></button></div>';
				form+="</div>";
			$("#credit_list").prepend(form);
		}
	});
	// header action : delete
	$('#header_content_div .delete').click(function(){
		if(!confirm('確定要刪除嗎？'))
			return false ;
		$.ajax({
			type: "POST",
  			url: "/course_maps/action_delete" ,
  			data:{
  				target_id : header_node.cf_id,
  			},	
  			success: function(data){
  				reset_data();
  				$('#alert-msg').removeClass().addClass('text-color-green').html('更新成功').show().fadeOut(2200);
  				load_treeview(0, map_id);
  				$('#course_content').empty() ;
  			},	
  			error: function(){
  				$('#alert-msg').removeClass().addClass('text-color-red').html('更新失敗').show().fadeOut(2200);
  			}
  		});
	});

	// header action : update
	$('#header_content_div .update').click(function(){
		if($(this).hasClass('edit')){
			if(!confirm('要送出嗎？'))
				return false ;
			var name = $('.field-header-name :input').val() ;
			var credit_need = $('.credit-need :input').val() ;
			var field_need = $('.field-need :input').val() ;
			var target_id = header_node.cf_id ;		
			if(!(name.length > 0) ){
				alert('data not complete');
				return false;
			}

			credit_need = (!credit_need) ? -1 : credit_need; //必修

			$.ajax({
				type: "POST",
	  			url: "/course_maps/action_update" ,
	  			data:{
	  				name : name,
	  				credit_need : credit_need,
	  				field_need : field_need,
	  				target_id : target_id,
	  			},	
	  			success: function(data){
	  				reset_data();		
	  				$('#alert-msg').removeClass().addClass('text-color-green').html('更新成功').show().fadeOut(2200);
	  				load_treeview(target_id, map_id);
	  			},	
	  			error: function(){
	  				reset_data();	
	  				$('#alert-msg').removeClass().addClass('text-color-red').html('更新失敗').show().fadeOut(2200);
	  			}		
	  		});			
		}else{		
			var header_tag = $('#header_content_div .header-type') ;
			var name_tag = $('#header_content_div .field-header-name') ;
			//var credit_tag = $('#header_content_div .credit-need') ;
			var field_tag = $('#header_content_div .field-need') ;
			header_tag.html(header_node.label).show();
			name_tag.html('<input type="text" value="'+header_node.name+'" class="form-control">');
			//if(header_node.credit_need!='N/A')
			//	credit_tag.html('<input type="text" value="'+header_node.credit_need+'" class="form-control">');
			if(field_tag)
				field_tag.html('<input type="text" value="'+header_node.field_need+'" class="form-control">');			
			$(this).html('<i class="fa fa-check"></i>').switchClass('btn-warning','btn-success');
			$(this).addClass('edit') ;			
		}
		
	});
	
	
	//header action : change field_type
	$('#header_content_div .change-type').click(function(){
		var ftype = $(this).attr('ftype');
		var target_id = header_node.cf_id ;
		if(!confirm( ((ftype==2) ? "要修改 x選y --\> 必修 嗎? " : "要修改 必修 --\> x選y 嗎?")))
			return false ;
		$.ajax({
			type: "POST",
  			url: "/course_maps/action_fchange" ,
  			data:{
  				target_id : target_id,
  			},	
  			success: function(data){
				load_treeview(target_id, map_id);
  			},	
  			error: function(){
  				$('#alert-msg').removeClass().addClass('text-color-red').html('更新失敗').show().fadeOut(2200);
  			}
  		});	
	});
	
}

function bind_course_group_but(){  // for course group
	$('.update-gtype').click(function(){
		var org_gtype = $('.update-gtype').attr('gtype') ;
		var gtype = (org_gtype==0) ? 1 : 0 ;
		var but_color = ['btn-warning', 'btn-info'];
		var but_text = (gtype==0) ? '代表' : '抵免' ;
		$.ajax({
			type: "POST",
  			url: "/course_maps/course_group_action" ,
  			data:{
  				type: 'update',
				target: 'gtype',
				gtype: gtype ,
  				cg_id : $('.list-header').attr('cg_id')
  			},
			success: function(){
				$('.update-gtype').attr('gtype', gtype).html(but_text);
				$('.update-gtype').switchClass(but_color[org_gtype], but_color[gtype]);
			},error: function(){
				alert('update course group failed..');
			}
		});	
	});
	$('.update-leader').click(function(){
		var cg_id = $('.list-header').attr('cg_id') ;
		var list_id = $(this).parent('td').parent('tr').attr('list_id');
		$.ajax({
			type: "POST",
  			url: "/course_maps/course_group_action" ,
  			data:{
  				type: 'update',
				target: 'leader',
  				cg_id : cg_id,
				list_id: list_id 
  			},
			success: function(){
				load_group_treeview(cg_id, map_id);
			},error: function(){
				alert('update course leader failed..');
			}
		});	
	});
	
	$('.delete-group').click(function(){
		if(!confirm('確定刪除嗎?'))
			return false ;
		$.ajax({
			type: "POST",
  			url: "/course_maps/course_group_action" ,
  			data:{
  				type: 'delete',
				target: 'cg',
  				cg_id : $('.list-header').attr('cg_id')
  			},
			success: function(){
				load_group_treeview(0, map_id);
				$('#course_content').empty();
			},error: function(){
				alert('delete course group failed..');
			}
		});	
	});
	
	
	
	$('.course-delete').click(function(){
		//console.log("delete");
		var list_tr = $(this).parent('td').parent('tr') ;
		var cg_id = $('.list-header').attr('cg_id') ;
		var list_id = list_tr.attr('list_id');
		$.ajax({
			type: "POST",
  			url: "/course_maps/course_group_action" ,
  			data:{
  				type: 'delete',
					target: 'cgl',
  				list_id : list_id,
					cg_id: cg_id
  			},
			success: function(){
				//list_tr.remove();
				load_group_treeview(cg_id, map_id);
				
			},error: function(){
				alert('delete course group list failed..');
			}
		});	
	});
}

function bind_course_list_button(){
	//course delete
	$('.course-table .course-delete').click(function(){
		var target_tr = $(this).parent('td').parent('tr') ;
		var list_id = target_tr.attr('list_id') ;
		//console.log(list_id);
		$.ajax({
			type: "POST",
			url: "/course_maps/course_action" ,
			data:{
				cf_id: cf_show_id,
				target_id : list_id,
				type : 'delete'
			},	
			success: function(data){
				//console.log(data);
				//target_tr.remove();
				res=JSON.parse(data);
				if(res.new_credit){
					$(".credit-need").text(res.new_credit);
				}
				$('.course-table [list_id='+list_id+']').remove();
			},	
			error: function(){
				alert('delete course failed.');
			}
		});
			
	});

	//course update
	$('.course-table .course-update').click(function(){
		var target_tr = $(this).parent('td').parent('tr') ;
		//console.log($(this).attr('rtype'));
		var rtype = ($(this).attr('rtype')==1) ? 0 : 1 ; // change credit-take

		var icon = $(this) ;
		var change_table1 = ['fa-check', 'fa-times'] ;
		var change_table2 = ['text-color-green', 'text-color-red'] ;
		$.ajax({
			type: "POST",
  			url: "course_action" ,
  			data:{
  				target_id : target_tr.attr('list_id'),
  				rtype : rtype,
  				type : 'update'
  			},	
  			success: function(data){
					
  				//console.log('course update success');
					res=JSON.parse(data);
					if(res.new_credit){
						$(".credit-need").text(res.new_credit);
					}
			
					icon.attr('rtype', rtype) ;
					icon.switchClass(change_table1[rtype], change_table1[(rtype+1)%2]);
					icon.switchClass(change_table2[rtype], change_table2[(rtype+1)%2]);
				
  			},	
  			error: function(){
  				alert('update course failed.');
  			}
  		});
	});
	// course grade & half update
	$('.grade-select, .half-select').change(function(){
		var target_tr = $(this).parent('td').parent('tr') ;
		var target = ($(this).attr('class')=="grade-select") ? "grade" : "half" ;
		var value = $(this).val();
		//console.log(target_tr.attr('list_id'));
		//return false ;
		$.ajax({
			type: "POST",
  		url: "/course_maps/course_action" ,
  		data:{
  				target_id : target_tr.attr('list_id'),
					type : 'update',
  				rtype : 2,
  				target : target,
					value: value
				},
			error: function(){
  				alert('update grade, half failed.');
  		}
		});			
	});
	
}

function genCreditList(data){
	//console.log(data);
	$("#credit_list").html(tmpl("xtmpl-credit-list",data));
	bind_credit_list_button();
}

function load_header_content(data){
	$("#header_content_div").html(tmpl("header-content-format", data));
	
	if(data.head_node.type>=1){
		$.getJSON("/course_maps/get_credit_list?id="+data.head_node.cf_id, function (data) {		
			
			genCreditList(data);
		});
	}
	bind_header_button(data.head_node);
}

function load_course_list(target_id){
	if(!target_id)
		return false;
	$.getJSON("/course_maps/show_course_list.json?target_id="+target_id, function (data) {
	//	console.log(data);
		$("#course_content").html(tmpl("table-format", data));	
		bind_course_list_button();
	});
	
	return true;
}
