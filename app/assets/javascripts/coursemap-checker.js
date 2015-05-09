/*
 * app/assets/javascript/coursemap-checker.js
 *
 * Copyright (C) 2014 NCTU+
 *
 * For user/statistics
 * 此檔案是check同學的通識及必選修有沒有過的演算法 
 *
 * Modified at 2015/3/24
 */
 
function commonCheck(pass_score,last_sem_id,user_courses){
	var result={}; 
	result['art_after102']=0; 
	result['phe_1']=0; 
	result['phe_optional']=0; 
	result['foreign_basic']=0; 
	result['foreign_advance']=0; 
	result['common']={}; 
	result['common']['通識']=0; 
	result['common']['公民']=0; 
	result['common']['群已']=0; 
	result['common']['歷史']=0; 
	result['common']['文化']=0; 
	result['common']['自然']=0; 

	var pass_courses=get_pass_courses(pass_score,last_sem_id,user_courses); 
	for(var i = 0,course;course=pass_courses[i];i++){ 

		if(course.name.search("服務學習")!=-1){ 
			if(course.name.search("一")!=-1){ 
				result['service_1']=true; 
			}
			else if(course.name.search("二")!=-1){ 
				result['service_2']=true; 
			} 
		} 
		else if(course.brief.search("藝文賞析")!=-1){ 
			if(course.sem_id>=7){ 
				++result['art_after102']; 
			} 
			if(course.name.search("一")!=-1){ 
				result['art_1']=true; 
			}
			else if(course.name.search("二")!=-1){ 
				result['art_2']=true; 
			} 
		} 
		else if(course.brief.search("體育")!=-1){ 
			if(course.name=="大一體育"){ 
				++result['phe_1']; 
			}
			else if(course.name.substr(0,2)=="體育"){ 
				++result['phe_optional']; 
			} 
		} 
		else if(course.cos_type=="外語"){ 
			if(course.brief=="基礎"){ 
				result['foreign_basic']+=parseInt(course.credit); 
			}
			else if(course.brief=="進階"||course.brief=="其它"){ 
				result['foreign_advance']+=parseInt(course.credit); 
			} 
		} 
		else if(course.cos_type=="通識"){
			var dimension=course.brief.substr(0,2);
			if(dimension.length==2)
			result['common'][dimension]+=parseInt(course.credit); 
		} 
	}
	return result;
}


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



