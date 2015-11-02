function showModal(target,size,title,content,callBack){
	var $obj=$("#"+target);
	switch(size){
		case 0:
			$obj.find(".modal-dialog").addClass("modal-sm");
			break;
		case 1:
			$obj.find(".modal-dialog").removeClass("modal-sm modal-lg");
			break;
		case 2:
			$obj.find(".modal-dialog").addClass("modal-lg");
			break;
	}
	
	if(title!=null)
		$obj.find(".modal-title").html(title);
	else
		$obj.find(".modal-header").hide();
		
	$obj.find(".modal-body").html(content);
	$obj.modal('show');
	$obj.off('hide.bs.modal');
	$obj.on('hide.bs.modal', function (event) {
		callBack();
	});
}

function showGlobalModal(size,title,content,callBack){
	showModal("global-modal",size,title,content,callBack);
}
function clearGlobalModalWithLoading(){
	var loading = '<i class="fa fa-spinner fa-spin text-center"></i>' ;
	$("#global-modal .modal-title").html(loading);
	$("#global-modal .modal-body").html(loading);
}