//= require page-tour/jquery.cookie
//= require page-tour/modernizr.mq
//= require page-tour/jquery.joyride-2.1


//If you want to use joyRide, please define it's id as joyRideTipContent
function showTip(){
	$('#joyRideTipContent').joyride("destroy");
	$('#joyRideTipContent').joyride({
		autoStart : true,
		cookieMonster: false
	});
}