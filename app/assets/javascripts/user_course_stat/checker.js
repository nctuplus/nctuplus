/*
 * app/assets/javascript/coursemap-checker.js
 *
 * Copyright (C) 2014 NCTU+
 *
 * For user/statistics
 * 此檔案是check同學的共同必修及課程地圖有沒有過的演算法 
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


function get_cf_list(cfs,course){
	
	var res=[];
	for(var i = 0,cf;cf=cfs[i];i++){
		_get_course_cf(res,null,cf,course);
		//console.log(cf);
	}

	var selected=0;
	for(var i = 0,cf;cf=res[i];i++){
		if(cf["id"]==course.cf_id){
			selected=i;
			break;
		}
	}
	var tmp=res[0];
	res[0]=res[selected];
	res[selected]=tmp;
	//console.log(res);
	return res;
}

function join_cf_courses(cf,courses){//將課程與領域做對應
	var res=[];
	for(var i = 0,course;course=courses[i];i++){
		if(course.cf_id==cf.id)
			res.push(course);
	}
	return res;
}

function check_course_match(uc,cf){
	for(var i = 0,course;course=cf.courses[i];i++){
		if(uc.cos_id==course.id)
			return true;
	}
	for(var i = 0,cg;cg=cf.course_groups[i];i++){
		for(var j = 0,course;course=cg.courses[j];j++){
		if(uc.cos_id==course.id)
			return true;
		}
	}
	
	return false;
}
function _get_course_cf(res,parent_cf,cf,course){
	if(cf.cf_type<3){
		if(check_course_match(course,cf)){
			var name=parent_cf ? parent_cf.cf_name+" - "+cf.cf_name : cf.cf_name;
			res.push({
				id:cf.id,
				name:name,
				match_credit:cf.match_credit,
				credit_list_match:cf.credit_list_match
			});
		}
	}
	else{
		//var res=[];
		for(var i = 0,_cf;_cf=cf.child_cf[i];i++){
			 _get_course_cf(res,cf,_cf,course);
		}
		//return res;
	}
}

function _check_user_course(user_courses, course){

	for(var j=0, user_course;user_course=user_courses[j];j++){
		if(course.id==user_course.cos_id)   // TODO : score judge
			return true;
	}
	return false;
}

// for bottom node, check match
function _cf_course_match(user_courses, cf){
	var match_credit = 0, c_match=true ;
	
	
	var joined_courses=join_cf_courses(cf,user_courses);
	for(var i = 0,cf_course;cf_course=cf.courses[i];i++){ // for each cf course
		
		if(_check_user_course(joined_courses, cf_course)){
			match_credit += cf_course.credit ;
		}else{
			c_match = false ;
		}
	}

	var cg_match = true ;
	if(cf.course_groups){
		for(var i = 0,course_group;course_group=cf.course_groups[i];i++){ // for each cg
			var local_match = false ;
			for(var j=0, cg_course; cg_course=course_group.courses[j];j++){
				if(_check_user_course(joined_courses, cg_course)){
					match_credit += cg_course.credit ;
					local_match = true ;
					break ;
				}	
			}
			if(!local_match)
				cg_match = false ;
		}
	}
	
	return {match_credit: match_credit, all_match: (c_match && cg_match)} ;
}

function check_cf(user_courses,cf){	//最上層的check

	switch(cf.cf_type){
		case 1:	//必修
			var res=_cf_course_match(user_courses, cf) ;
			cf.match_credit=res.match_credit;
			return {match_credit: res.match_credit, result: res.all_match};		
			break;
		case 2:	//X選Y
			var res = _cf_course_match(user_courses, cf) ;
			var match = (res.match_credit >= cf.credit_need) ? true : false;
			var match_arr=[];
			for(var j = 0, credit; credit=cf.credit_list[j]; j++){
				match_arr.push(res.match_credit >= credit.credit_need);
			}
			cf.match_credit=res.match_credit;
			return {match_credit: res.match_credit, result: match,new_result:match_arr}; 		
			break;
		case 3:	//領域群組
			var match_credit = 0, match_field = 0,sub_res=[] ;
			for(var i = 0, sub_cf;sub_cf=cf.child_cf[i];i++){
				var res = check_cf(user_courses, sub_cf) ;
				match_credit += res.match_credit ;
				if(res.result)
					match_field++;
				sub_res.push({
					cf_name: res.cf_name,
					result: res.result,
					res_text: res.match_credit+"/"+sub_cf.credit_need
				});
			}
			var match = (match_field >= cf.field_need && match_credit >= cf.credit_need);	
			return {match_credit: match_credit, match_field: match_field, result: match, sub_res: sub_res}; 
			break;
		case 4:	//領域
			var match_credit = 0, match = true;
			var credit_all = 0 ;
			for(var i = 0, sub_cf; sub_cf=cf.child_cf[i]; i++){
				credit_all += sub_cf.credit_need ;	//sum of credit for this field
			}

			var final_res=[];
			for(var i = 0, sub_cf; sub_cf=cf.child_cf[i]; i++){
				if(sub_cf.credit_need==0)	//if 必修,看無QQ
					sub_cf.credit_need = cf.credit_need - credit_all ;
				var res = check_cf(user_courses, sub_cf) ;
				match_credit += res.match_credit ;
				if(sub_cf.cf_type==2){
					if(final_res.length==0)
						final_res=res.new_result;
					else{
						for(var j = 0 ; j<res.new_result.length;j++){
							final_res[j]=final_res[j] && res.new_result[j];
						}					
					}
				}
				else{ //if 必修 
					match = res.result ;
				}				
			}
			for(var i = 0, sub_cf; sub_cf=cf.child_cf[i]; i++){
				if(sub_cf.cf_type==2){				
					for(var j = 0 ; j<final_res.length;j++){
						if(final_res[j]){
							sub_cf["credit_list_match"]={
								name: sub_cf.credit_list[j].name,
								credit_need: sub_cf.credit_list[j].credit_need,								
							}
							break;
						}
					}
				}
			}
			var i = 0;
			if(match){	//if 必修 match才判斷選修
				var any_match=false;			
				for(; i<res.new_result.length;i++){				
					if(final_res[i]){
						any_match=true;
						break;
					}
				}
				match=match&&any_match;//match 必修 and one of 選修's credit list
			}
			return {
				cf_name: cf.cf_name,
				match_credit: match_credit,
				result: match,
				//match_index:i
			}; 
			break;
	}
}




