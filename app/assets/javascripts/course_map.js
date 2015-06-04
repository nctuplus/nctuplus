function show_course(){
	//alert("F");
	
		$( "table" ).click(function(event){

			alert("tes");
			$( ".tooltip-course" ).css({
			"left": "event.pageX",
			"top": "event.pageY",
			"display": "block"
				});
			});
	}
$(document).ready(function(){
		show_course();
	});