function RotateImages(Start)
{
	//var ImageHolder1 = document.getElementById("bg");

	if (Start == 0)
	{
		$('#bg3').fadeOut(3000);
		$('#bg1').fadeIn(3000);
	}

	else if (Start == 1)
	{
		$('#bg1').fadeOut(3000);
		$('#bg2').fadeIn(3000);
	}
	
	else
	{
		$('#bg2').fadeOut(3000);
		$('#bg3').fadeIn(3000);
		Start = -1;
	}
	
	window.setTimeout("RotateImages("+(Start+1)+")",7500);
}

function onPageLoad()
{
	//window.setTimeout("RotateImages(1)",7500);

}