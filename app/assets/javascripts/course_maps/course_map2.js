function show_course(){
	//.btn-course class的效果
	$( ".btn-course" ).mouseover(function(event){
		var offset = $( this ).offset();
		var id1 = $(this).attr('id');
		var str="#"+id1;
		var sty=("2px "+$(str).css("background")+" solid");
			$( ".tooltip-course" ).css({
			"left": (event.pageX-306),
			"top": (event.pageY-35),
			"display": "block",
			"border-color":$(str).css("background-color")
				});
			$( ".course-name" ).css({
			"background-color":$(str).css("background-color")
				});
			})
			.mousemove(function(event){
			var id1 = $(this).attr('id');
			var color1="#FF0080";
			var str="#"+id1;
			//alert("event.pageX");
			var sty=("2px "+$(str).css("background")+" solid");
			$( ".tooltip-course" ).css({
			"left": (event.pageX-306),
			"top": (event.pageY-70),
			"display": "block",
			"border-color":$(str).css("background-color")
				});
			$( ".course-name" ).css({
			"background-color":$(str).css("background-color")
				});
			})
			.mouseout(function(event){
				
			var id1 = $(this).attr('id');
			var color1="#FF0080";
			
			//alert("event.pageX");
			$( ".tooltip-course" ).css({
			"display": "none",
			
				});
			});
		$( ".tooltip-course" ).mouseover(function(){
			$( this ).css({
			"display": "block"
			});
			})
			.mousemove(function(event){
			
			$( this ).css({
			"display": "block"
			});
			})
			.mouseout(function(event){
			
			//alert("event.pageX");
			$( this).css({
			"display": "none",
				});
			});
}
$(document).ready(function(){
		show_course();
		
	});