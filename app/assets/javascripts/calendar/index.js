var currentdate = new Date(); 
var cyear = currentdate.getFullYear();
var cmonth = currentdate.getMonth();
var cdate = currentdate.getDate();
var cday = currentdate.getDay();

var selectedMonth = cmonth;
var selectedYear = cyear;


var firstDate = new Date(selectedYear, selectedMonth, 1);
var firstDateDay = firstDate.getDay();

var PreMon = new Date(selectedYear, selectedMonth, 0);
var PreMonLastDate = PreMon.getDate();

var firstSundayDate = PreMonLastDate - firstDateDay+1 ;

var LastDate = new Date(selectedYear, selectedMonth+1, 0);
var ThisMonLastDate = LastDate.getDate();


function refreshSelctedMonth(){
  
  firstDate = new Date(selectedYear, selectedMonth, 1);
  firstDateDay = firstDate.getDay();

  PreMon = new Date(selectedYear, selectedMonth, 0);
  PreMonLastDate = PreMon.getDate();

  if(firstDateDay == 0)
    firstSundayDate = 1;
  else
    firstSundayDate = PreMonLastDate - firstDateDay+1 ;

  LastDate = new Date(selectedYear, selectedMonth+1, 0);
  ThisMonLastDate = LastDate.getDate();

}

function refreshDate() {
  var i;
  var tempDate = firstSundayDate;
  var monOffset = -1;
  if(tempDate == 1) monOffset = 0;

  for(i=0; i<42; i++){

    if(monOffset != 0)
      $(".date-box").eq(i).addClass("not-this-month");
    else{
      $(".date-box").eq(i).removeClass("not-this-month");
      if(tempDate == cdate && selectedMonth == cmonth){
        $(".date-box .date").eq(i).addClass("date-today");
        $(".date-box").eq(i).addClass("box-today");
      }else{
        $(".date-box .date").eq(i).removeClass("date-today");
        $(".date-box").eq(i).removeClass("box-today");
      }
    }
    $(".date").eq(i).text(tempDate);

    if(monOffset == -1 && tempDate == PreMonLastDate){
      tempDate = 1;
      monOffset++;
    }else if(monOffset == 0 && tempDate == ThisMonLastDate){
      tempDate = 1;
      monOffset++;
    }else
      tempDate++;



  }
}

function nxtMonth() {
  $("#cal-date").hide().fadeIn(300);

  if(selectedMonth == 11){
    selectedMonth = 0;
    selectedYear++;
  }else selectedMonth++;
  refreshSelctedMonth()
  refreshDate(); 
  $("h2").eq(0).text( (selectedMonth+1) + "月 " + selectedYear);
}

function preMonth() {
  $("#cal-date").hide().fadeIn(300);

  if(selectedMonth == 0){
    selectedMonth = 11;
    selectedYear--;
  }else selectedMonth--;
  refreshSelctedMonth()
  refreshDate(); 
  $("h2").eq(0).text( (selectedMonth+1) + "月 " + selectedYear);
}

function thisMonth() {
  $("#cal-date").hide().fadeIn(300);

  selectedMonth = cmonth;
  selectedYear = cyear;
  refreshSelctedMonth()
  refreshDate(); 
  $("h2").eq(0).text( (selectedMonth+1) + "月 " + selectedYear);
}



$("#cal-date").hide();


$(document).ready(function(){

  $("#cal-date").hide().fadeIn(500);

  refreshDate(); 
  $("h2").eq(0).text( (selectedMonth+1) + "月 " + selectedYear);


  $(".tag-cale").hide();
  $(".tag-info").hide();
  $("#btn-bell").addClass("selected");

  $("#btn-cale").click(function(){
    $(".tag-cale").fadeIn();
    $(".tag-info").fadeOut();
    $(".tag-bell").fadeOut();
    $("#btn-cale").addClass("selected");
    $("#btn-info").removeClass("selected");
    $("#btn-bell").removeClass("selected");
  });

  $("#btn-info").click(function(){
    $(".tag-cale").fadeOut();
    $(".tag-info").fadeIn();
    $(".tag-bell").fadeOut();
    $("#btn-cale").removeClass("selected");
    $("#btn-info").addClass("selected");
    $("#btn-bell").removeClass("selected");
  });

  $("#btn-bell").click(function(){
    $(".tag-cale").fadeOut();
    $(".tag-info").fadeOut();
    $(".tag-bell").fadeIn();
    $("#btn-cale").removeClass("selected");
    $("#btn-info").removeClass("selected");
    $("#btn-bell").addClass("selected");
  });


  $("#bar1").click(function(){
        $("#bar1").nextAll().toggle("fast");
    });

  
  $("#bar2").click(function(){
        $("#bar2").nextAll().toggle("fast");
    });
  
  $("#bar3").click(function(){
        $("#bar3").nextAll().toggle("fast");
    });
  
  $("#bar4").click(function(){
        $("#bar4").nextAll().toggle("fast");
    });

  $("#bar5").click(function(){
        $("#bar5").nextAll().toggle("fast");
    });

/*
  $('.content').popover({
        content: $(".content").html(),
        placement:"auto",
        trigger : "hover",
      });

*/
//  var hey = new Date(1498581000000);
//  alert(hey);

});
