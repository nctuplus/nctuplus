/*
 * Copyright (C) 2014 NCTU+
 *
 * For check score (need in many places so include globally)
 *
 */
function getPassCourses(func,pass_score,courses){
	var res=[];
	
	for(var i = 0,course;course=courses[i];i++){
		if(func(pass_score,course.score))/*成績通過*/
			res.push(course);
	}
	return res;
}

function checkPass(pass_score,score){
	return score=="通過" || ( isInt(score) && (parseInt(score) >= pass_score) );
}
function isInt(score){
	return !isNaN(parseInt(score));
}
function withdrawal(score){
	return score=="W";
}
function isTaking(score){
	return score=="修習中";
}
function checkPassTaking(pass_score,score){
	return  isTaking(score) || checkPass(pass_score,score);
}
function roundToDec(number,dec){
	var n=Math.pow(10,dec);
	return Math.round(number * n) / n;
}