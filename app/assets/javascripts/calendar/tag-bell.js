//
// tag-bell.js 
//  
// Jobs:
// create/delete tag-bell html/css from input data
//
// Js import directive for RoR:
//= require calendar/calendar.js


var tagBell = {

      
  /**
   * 清除tag-bell中所有HTML。
   */
  clear: function() {
    $('.count-down').remove();
    $('.e3').remove();
  },

  setTagBell: function(){
    tagBell.clear();
  }
  


}