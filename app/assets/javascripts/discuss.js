/*
 *
 * Copyright (C) 2015 NCTU+
 *
 * For discuss controller (in course/show)
 *
 * Modified at 2015/4/24
 */
 

function show_sub_form(id,enabled){
	if(enabled){
		$(".sub-form").html("");
		$("#sub_form_"+id).html('<%=j render "sub_discuss_form" %>');
		$("#reply_discuss_id").val(id);
		$("#sub_content").focus();
	}else{
		alert("請先登入!");
	}
}
function like(_like,type,id,obj){

	$.ajax({
		type: "GET",
		url: "/discusses/like",
		data: {
			type: type,
			discuss_id: id,
			like: _like,   
		},
		success: function(data){
			obj.next().text(parseInt(obj.next().text())+1);
			obj.parent().find(".clickable-hover").attr("onclick","");
			obj.parent().find(".clickable-hover").removeClass("clickable-hover");
		},
		error:function(){
			toastr["info"]("您已按過讚!");
			obj.parent().find(".clickable-hover").attr("onclick","");
			obj.parent().find(".clickable-hover").removeClass("clickable-hover");
		}
	});
}