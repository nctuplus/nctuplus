/*
 * Copyright (C) 2014 NCTU+
 *
 * 對一個Hash array的某一個Key 做 grouping
 * For User#special_list & User#all_courses
 * Modified at 2015/3/24
 */
 
function groupBy( array , f ){
  var groups = {};
  array.forEach( function( o )
  {
    var group = JSON.stringify( f(o) );
    groups[group] = groups[group] || [];
    groups[group].push( o );  
  });
  return Object.keys(groups).map( function( group )
  {
    return groups[group]; 
  })
}

function groupBy2( array , f ){
  var groups = {};
  array.forEach( function( o ){
    var group = JSON.stringify( f(o) );
    groups[group] = groups[group] || [];
    groups[group].push( o );  
  });
  return groups;
}
