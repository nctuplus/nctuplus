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