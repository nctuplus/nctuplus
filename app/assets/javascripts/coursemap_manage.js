//= require bootstrap-treeview

function load_treeview(target_id, map_id){
		
	$.getJSON( "get_course_tree.json?map_id="+map_id, function(res){
		console.log('load course tree success');
		$('#course_tree').treeview({data: res, map_id: map_id});
		if (target_id!=0){
			$('#course_tree').treeview('activateNode', ['cf_id', target_id]);
		}
	});
	alert(map_id);
	return ;
}

function load_group_treeview(target_id, map_id){
	$.getJSON( "get_group_tree.json?map_id="+map_id, function(res){
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