/*
 * Copyright (C) 2014 NCTU+
 * 
 * For past_exams/list_by_ct , edit function control
 *  
 * Updated at 2015/4/28
 */
 
//= require jquery-fileupload
 
var fileUploadErrors = {
  maxFileSize: 'File is too big',
  minFileSize: 'File is too small',
  acceptFileTypes: '格式不支援!',
  maxNumberOfFiles: 'Max number of files exceeded',
  uploadedBytes: 'Uploaded bytes exceed file size',
  emptyResult: 'Empty file upload result'
};

function update_input(obj){ 
	obj.next().val(obj.val());
}
/*
function change_to_edit(file,semester_select){

	//var semester_select="<%=j select_tag("past_exam[semester_id]", options_from_collection_for_select(@sems, "id", "name"))%>";
	$("#download_"+file.id+" td[class=semester_"+file.id+"]").html(semester_select);
	$("td.semester_"+file.id+" select").val(file.semester_id);
	
	var description_input='<input rows="1" name="past_exam[description]" value="'+file.description+'">';
	$("#download_"+file.id+" td[class=description_"+file.id+"]").html(description_input);
	
	$("#edit_but_"+file.id).hide();
	$("#save_but_"+file.id).show();
	$("#delete_"+file.id).show();
	
}
*/