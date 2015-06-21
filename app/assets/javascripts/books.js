//= require jquery-fileupload

$(function(){
	if($("#book_trade_info_price").val()=="")
		$("#book_trade_info_price").attr("disabled","true");
	$('#book_trade_info_cover').change(function (e) {
		var file=e.target.files[0];
		if(file.size>=2097152){
			toastr["warning"]("檔案需小於2MB!");
			e.preventDefault();
			return false;
		}
		loadImage(
			file,
			function (img) {
				$("#image-container").html(img);
			},
			{maxHeight:170} // Options
		);
	});
	
	$("#search-ct").bind({
		keydown:function(e){
			var key = e.which || e.keyCode;
			if (key == 13){
				e.preventDefault();
				$("#search-ct-btn").click();
			}
		},
		blur:function(e){
			$("#search-ct-btn").click();
		}
	});
	
	$('.integer-only').keypress(function(e){//0~9 only
		var key = e.which || e.keyCode;
		if (!(key >= 48 && key <= 57) && // Interval of values (0-9)
				 (key !== 8) &&              // Backspace
				 (key !== 9)){             // Horizontal tab
			e.preventDefault();
			return false;
		}
	});
	
	$("#book_trade_info_book_name").keypress(function(event){
		if (event.keyCode == 13){
			event.preventDefault();
			$("#search-GoogleBook").click();
		} 
	});
	
	$("#book_trade_info-form").submit(function(){
		
		var price_input=$("#book_trade_info_price");
		console.log(parseInt(price_input.val()));
		if(!/^\d+$/.test(price_input.val()) || parseInt(price_input.val())<=0){//check price integer && not 0
			toastr["warning"]("價格需為正整數!");
			price_input.focus();
			return false;
		}
		if($("#cts_id_list").val()==""&&!confirm("尚未輸入適用課程,仍要送出?")){
			$("#cts_id_list").focus();
			return false;
		}
		fillCtIdList();
		if($("#book_selected").val()=="false"){
			fillBookInput(
				$("#book_trade_info_book_name").val(),
				$("#book_isbn").val(),"","","",""
			);
		}
		return true;
	});

});

function checkAndEnable(){
	if($("#book_trade_info_book_name").val()!=""){
		//console.log("!!!!!!");
		$("#book_trade_info_price").removeAttr('disabled');
		//$("#book_trade_info_price").attr("disabled","false");
	}
}

function showPreviewImg(){
	if($("#book_trade_info_book_name").val()==""){
		toastr["warning"]("請先輸入書名!");
	}
	else{
		$('#book_trade_info_cover').click();
	}
}
function fillBookInput(title,isbn,authors,image_link,description,preview_link){
	$("#book_image_link").val(image_link);
	$("#book_title").val(title);
	
	$("#book_isbn").val(isbn);
	if(isbn!="")$("#book_isbn").attr("disabled","");
	$("#book_authors").val(authors);
	$("#book_description").val(description);
	$("#book_preview_link").val(preview_link);
}
function selectBook(title,isbn,authors,image_link,description,preview_link){
	$("#book_trade_info_book_name").val(title);
	var img="<img alt='無圖片' style='height:170px;' src='"+image_link+"'>";
	$("#image-container").html(img);
	$("#book_selected").val("true");
	fillBookInput(title,isbn,authors,image_link,description,preview_link);
	toastr["success"]("已選擇 "+title+" (From Google Book)")
	closeGlobalModal();
}

function searchCourse(){
	var last_term=$("#last-ct-search-term").text();
	if($("#search-ct").val()==""){
		toastr["warning"]("請輸入課程名稱!");
		return;
	}
	if(last_term!=$("#search-ct").val()){
		$("#q_course_ch_name_cont").val($("#search-ct").val());
		$("#course_teachership_search").submit();
		$("#last-ct-search-term").text($("#search-ct").val());
	}
	else{
		justShowGlobalModal();
	}
}
function fillCtIdList(){
	var ids=[];
	$("#cts-list li").each(function(){
		ids.push($(this).attr("id"));
	});
	$("#cts_id_list").val(ids);
	//$("#cts_id_list").val(JSON.stringify(ids));
}
function removeCtId(id){
	$("li[id="+id+"]").remove();
}
function addCtid(id,course_name,teacher_name){
	if($("#cts-"+id).prop("checked")){
		if($("#cts-list").find("li[id="+id+']').length==0)
			$("#cts-list").append("<li id='"+id+"'>"+course_name+' '+teacher_name+"</li>");
	}
	else{
		$("#cts-list").find("li[id="+id+']').remove();
	}
}
function searchGoogleBook(){
	var title=$("#book_trade_info_book_name").val();
	if(title==""){
		toastr["warning"]("請先輸入書名!");
		return;
	}
	$.ajax({
		type : "POST",
		data : {title : title},
		url : "/books/google_book",
		success : function(data) {
			console.log(data);
			var content=tmpl("googlebook-res",data);
			showGlobalModal(title, content);
		}
	});
	
}