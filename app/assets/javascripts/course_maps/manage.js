//= require bootstrap-treeview

function load_treeview(target_id, map_id){
	$.getJSON( "/course_maps/get_course_tree.json?map_id="+map_id, function(res){
		//console.log('load course tree success');
		$('#course_tree').treeview({data: res, map_id: map_id});
		if (target_id!=0){
			$('#course_tree').treeview('activateNode', ['cf_id', target_id]);
		}
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
  			url: "/course_maps/action_new" ,
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
	//cg_show_id = null ;cf_show_id = null ;
	$('#header_content_div').empty();
	// reset course list content
	//$('#course_content').empty();

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
			$(this).html('<i class="fa fa-check"></i>').toggleClass('btn-warning btn-success');
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
		if(!confirm('確定要刪除嗎?(此操作不可逆!!)'))
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
			$(this).html('<i class="fa fa-check"></i>').removeClass("btn-info").addClass('btn-success');
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

//Course Group Functions start

function setToLeadCourse($obj){
	var $tr = $obj.parent('td').parent('tr');
	var cg_id = $tr.parent('tbody').parent('table').attr('cg_id') ;
	var cgl_id = $tr.attr('cgl_id');
	$.ajax({
		type: "POST",
			url: "/course_maps/course_group_action" ,
			data:{
				type: 'update',
				target: 'leader',
				cg_id : cg_id,
				cgl_id: cgl_id 
			},
		success: function(data){
			//console.log(data);
			var res=$.parseJSON(data);
			if(res.new_credit!=0){
				$(".credit-need").text(res.new_credit);
			}
			var $table_body = $tr.parent();
			$table_body.html(tmpl("cg-rows-tmpl",res.cg)).promise().done(function(){
				showAllCgl(cg_id);
				//alert("!!!!");
				//$(this).find(".toggle-group").click();
			});
			
		},error: function(){
			alert('update course leader failed..');
		}
	});	
}



function toggleGroup(cg_id){
	$tbl_body=$("table[cg_id='"+cg_id+"']").find("tbody");
	$but=$tbl_body.find(".toggle-group");
	if($but.hasClass("fa-plus")){
		showAllCgl(cg_id);
	}
	else{
		hideAllCgl(cg_id);
	}
}
function showAllCgl(cg_id){
	$tbl_body=$("table[cg_id='"+cg_id+"']").find("tbody");
	$but=$tbl_body.find(".toggle-group");
	$but.removeClass("fa-plus").addClass("fa-minus");
	$rows=$tbl_body.find(".sub_tr");
	$rows.show();
}
function hideAllCgl(cg_id){
	$tbl_body=$("table[cg_id='"+cg_id+"']").find("tbody");
	$but=$tbl_body.find(".toggle-group");
	$but.removeClass("fa-minus").addClass("fa-plus");
	$rows=$tbl_body.find(".sub_tr");
	$rows.hide();
}
function selectCg($obj){
	var $list_tr = $obj.parent('td').parent('tr') ;
	var $table = $list_tr.parent('tbody').parent('table') ;
	var course_name = $list_tr.find(".course_name").text();
	var cg_id=$table.attr("cg_id");
	$("#tips-area").text("從左側加入課程至: "+course_name);
	$("#add-target").text("cg");
	showAllCgl(cg_id);
	$("#dis-select-cg").show();
	$("#cg-id").text(cg_id);
		
}

function disSelectCg(){
	$("#add-target").text("cf");	//set target to course field
	$("#cg-id").text("0");	//reset cg-id
	$("#tips-area").text("");
	$("#dis-select-cg").hide();
	
}

function deleteCgl($obj){
	var $list_tr = $obj.parent('td').parent('tr') ;
	var cg_id = $list_tr.attr('cg_id') ;
	var cgl_id = $list_tr.attr('cgl_id');
	$.ajax({
		type: "POST",
			url: "/course_maps/course_group_action" ,
			data:{
				type: 'delete',
				target: 'cgl',
				cgl_id : cgl_id,
				cg_id: cg_id
			},
		success: function(){
			toastr["info"]("刪除成功");
			$list_tr.remove();
			//load_group_treeview(cg_id, map_id);
			
		},error: function(){
			alert('delete course group list failed..');
		}
	});
}

function deleteCg($obj){
	var $list_tr = $obj.parent('td').parent('tr');
	var $table = $list_tr.parent().parent();
	var cg_id = $table.attr('cg_id');
	var cf_id = $('#cf-id').text();

	if(!confirm('將會刪除整個課程群組,確定嗎?'))
		return false ;
	$.ajax({
		type: "POST",
			url: "/course_maps/course_group_action" ,
			data:{
				type: 'delete',
				target: 'cg',
				cg_id: cg_id,
				cf_id: cf_id
			},
		success: function(data){
			toastr["info"]("刪除群組: " +$list_tr.find(".course_name").text()+ "成功!");
			if($("#cg-id").text()==cg_id){//if cg_id is selecting
				disSelectCg();
			}
			$("table[cg_id='"+cg_id+"']").remove();
			var res=$.parseJSON(data);
			if(res.new_credit!=0){
				$(".credit-need").text(res.new_credit);
			}
		},error: function(){
			alert('delete course group failed..');
		}
	});	

}
function switchCgType($obj){
	var $list_tr = $obj.parent('td').parent('tr') ;
	var cg_id = $list_tr.attr('cg_id');
	var org_gtype = $list_tr.attr('gtype') ;
	var new_gtype = (org_gtype==0) ? 1 : 0 ;	//switch 
	//var but_color = ['btn-warning', 'btn-info'];
	var new_text = (new_gtype==0) ? '[代]' : '[抵]' ;
	var full_text = (new_gtype==0) ? '代表' : '抵免' ;
	var course_name = $list_tr.find(".course_name").text();
	$.ajax({
		type: "POST",
			url: "/course_maps/course_group_action" ,
			data:{
				type: 'update',
				target: 'gtype',
				gtype: new_gtype ,
				cg_id : cg_id
			},
		success: function(){
			toastr["info"]("成功更新 "+course_name+"為: "+full_text);
			$list_tr.find("span[class='gtype']").text(new_text);
			$list_tr.attr("gtype",new_gtype);
		},error: function(){
			alert('update course group failed..');
		}
	});	
}
function createCg($obj){
	if(!confirm('建立課程群組,確定嗎?'))
		return false ;
	var $list_tr = $obj.parent('td').parent('tr');
	var cfl_id= $list_tr.attr("cfl_id");
	var cm_id = $("#cm-id").text();
	$.ajax({
		type: "POST",
			url: "/course_maps/course_group_action" ,
			data:{
				type: 'new',
				cm_id: cm_id,
				cfl_id: cfl_id
			},
		success: function(data){
			_data=$.parseJSON(data);
			$("#cg-div").prepend(tmpl("cg-single-tbl-tmpl",_data)).promise().done(function(){
				$("table[cfl_id='"+cfl_id+"']").find("#select-cg-but").click();
				showTips();
				//alert("!!!");
			});
			$list_tr.parent().parent().remove();
			toastr["info"]("新增課程群組: "+_data.courses[0].course_name);
			//$list_tr.find("span[class='gtype']").text(new_text);
			//$list_tr.attr("gtype",new_gtype);
		},error: function(){
			alert('update course group failed..');
		}
	});	
	
}
function toggleCflRtype($obj){
	var $target_tr=$obj.parent().parent();
	var new_rtype = $target_tr.attr('rtype')=="1" ? 0 : 1 ; // change credit-take
	
	var class_table = ['fa-check text-color-green', 'fa-times text-color-red'] ;
	var tips_table = ['採計學分', '不採計學分'] ;
	$.ajax({
		type: "POST",
			url: "/course_maps/course_action" ,
			data:{
				cfl_id : $target_tr.attr('cfl_id'),
				target: "record_type",
				rtype : new_rtype,
				type : 'update'
			},	
			success: function(data){
				res=JSON.parse(data);
				if(res.new_credit){
					$(".credit-need").text(res.new_credit);
				}
				$target_tr.attr('rtype', new_rtype) ;
				$obj.removeClass(class_table[(new_rtype+1)%2]).addClass(class_table[(new_rtype)]);
				$obj.attr("data-content",tips_table[new_rtype]);
			
			},	
			error: function(){
				alert('update course failed.');
			}
	});

	
}

function deleteCfl($obj){
	var $list_tr = $obj.parent('td').parent('tr') ;
	var cfl_id = $list_tr.attr('cfl_id') ;
	//console.log(list_id);
	$.ajax({
		type: "POST",
		url: "/course_maps/course_action" ,
		data:{
			type : 'delete',
			cfl_id : cfl_id
		},	
		success: function(data){
			res=JSON.parse(data);
			if(res.new_credit){
				$(".credit-need").text(res.new_credit);
			}
			$list_tr.parent().parent().remove();
			//$('.course-table [list_id='+list_id+']').remove();
		},	
		error: function(){
			alert('delete course failed.');
		}
	});
}
function changeGradeHalf($obj,target){
	var $target_tr = $obj.parent('td').parent('tr') ;
	var $table=$target_tr.parent().parent();
	var cfl_id=$table.attr("cfl_id");
	var value = $obj.val();
	$.ajax({
		type: "POST",
		url: "/course_maps/course_action" ,
		data:{
				cfl_id : cfl_id,
				type : 'update',
				target : target,
				value: value
		},
		success:function(){
			toastr["info"]("更新成功");
		},
		error: function(){
				alert('update grade, half failed.');
		}
	});
}

function genCreditList(data){
	//console.log(data);
	$("#credit_list").html(tmpl("xtmpl-credit-list",data));
	bind_credit_list_button();
}

function load_header_content(data){
	$("#header_content_div").html(tmpl("header-content-format", data));
	showTips();
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
	$.getJSON("/course_maps/get_course_group?cf_id="+target_id, function (data) {
		$("#cg-div").html(tmpl("cg-table-tmpl", data));			
		showTips();
	});	
	
	$.getJSON("/course_maps/get_course_list?cf_id="+target_id, function (data) {
		$("#course-list-div").html(tmpl("normal-course-table-tmpl", data));	
		showTips();
	});
	
	return true;
}
function showTips(){
	$("[data-toggle='popover']").popover({
		trigger:"hover",
		placement:"bottom",
		html:true
	});
}


function addCourse(c_ids){ //action="add"
	var target=$("#add-target").text();
	
	if(target=="cf"){
		var cf_id=$("#cf-id").text();
		if(cf_id=="0"){
			toastr["warning"]("請先選擇一個 [必修] 或 [多選多] 類別");
			return false ;	
		}
		$('#alert-msg').removeClass().html('<%=j fa_icon "spinner spin"%>');	
		$.ajax({
			type: "POST",
			url: "/course_maps/course_action" ,
			data:{
				type: 'create_cfl',
				cf_id : cf_id,
				c_ids : c_ids,
				map_id : map_id,
			},	
			success: function(data){ 
				var res = $.parseJSON(data);
				$("#course-list-div").append(tmpl("normal-course-table-tmpl",res.cfl));
				//console.log(res);
				if(res.cfl_same_cnt > 0 ){
					toastr["warning"]("有 "+res.cfl_same_cnt+"門一般課程重複了!");	
				}
				if(res.cgl_same_cnt > 0){
					toastr["warning"]("有 "+res.cgl_same_cnt+"門課程群組中的課程重複了!");	
				}
				$('#alert-msg').html('新增成功').removeClass().addClass('text-color-green').show().fadeOut(3000);
				if(res.new_credit!=0){
					$(".credit-need").text(res.new_credit);
				}
			},
			error: function(){
				$('#alert-msg').html('新增失敗').removeClass().addClass('text-color-red').show().fadeOut(3000);	
				alert("Add course failed..");
			}
		});	
	}
	else if(target=="cg"){
		var cg_id=$("#cg-id").text();
		if(cg_id=="0"){
			toastr["warning"]('請先選擇一個群組!');
			return false;
		}
		$.ajax({
				type: "POST",
					url: "/course_maps/course_action" ,
					data:{
						type: 'create_cgl',				
						cg_id : cg_id,
						c_ids : c_ids
					},	
					success: function(data){
						$tbl_body=$("table[cg_id='"+cg_id+"']").find("tbody");
						var res = $.parseJSON(data);		
						if(res.cfl_same_cnt > 0 ){
							toastr["warning"]("有 "+res.cfl_same_cnt+"門一般課程重複了!");	
						}
						if(res.cgl_same_cnt > 0){
							toastr["error"]("有 "+res.cgl_same_cnt+"門課程群組中的課程重複了!");	
						}
						for(var i=0,cgl;cgl=res.cgl[i];i++){
							cgl["show"]=true;
							$tbl_body.append(tmpl("cg-sub-row-tmpl",cgl));
						}
						showAllCgl($tbl_body);
						$('#alert-msg').html('新增成功').show().fadeOut(3000);
					},
					error: function(){
						alert("Add course failed..");
					}
			});	
	}
	else{
		alert("Error!!!");
	}
	return false ;
}
function addAllCourses(){
	//if(!check_field_selected())return;
	var arr=[];
	$("tr.course").each(
	function(){
		//console.log($(this).attr('id'));
		arr.push($(this).attr('id'));
	});
	if(confirm("確定加入共"+arr.length+"課程?")){
		addCourse(arr);
	}
}

function updateUserCflId($obj){
	if(!confirm("使用此地圖的使用者將會重新計算學分\n"
			+"請務必做完所有修改後再送出通知。\n\n"
			+"您確定要送出嗎?")){
		return false ;
	}
	$obj.attr("disabled", true);
	$.ajax({
		type: "POST",
		url: "/course_maps/notify_user" ,
		data:{
			map_id: $("#cm-id").text(),
		},	
		success: function(res){								
			toastr["success"]("更新成功");
			setTimeout(function(){
				$obj.attr("disabled", false);
			}.bind(this), 5000);
		}.bind(this),	
		error: function(){
			alert("internal server error.");
		}
	});
}