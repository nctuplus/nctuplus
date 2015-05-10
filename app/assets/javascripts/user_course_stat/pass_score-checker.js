/*
 * Copyright (C) 2014 NCTU+
 *
 * For check score (need in many place)
 *
 * Modified at 2015/5/11
 */
function get_pass_courses(pass_score,last_sem_id,courses){
	var res=[];
	
	for(var i = 0,course;course=courses[i];i++){
		if(check_pass(pass_score,course.score))/*成績通過*/
			res.push(course);
	}
	return res;
}

function check_pass(pass_score,score){
	return score=="通過" || score=="修習中" || parseInt(score)>=pass_score
}