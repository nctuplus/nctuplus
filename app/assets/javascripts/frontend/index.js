//
// index.js 
//  

$(document).ready(function(){

  
  $("h1").click(function(){
  	$(this).fadeOut();
  });

  for(var i=0; i<5; i++){
  	$(".something-loop").append('<h2>' + i*i + '</h2>');
  }

});
