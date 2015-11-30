//= require jquery-ui-timepicker-addon
//= require jquery-fileupload

function initUpload(){
	$('#event_cover').change(function (e) {
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
}