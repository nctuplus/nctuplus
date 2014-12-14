function get_check_res(pass_score,last_sem_id,user_courses){
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
			result['common'][course.brief.substr(0,2)]+=parseInt(course.credit); 
		} 
	}
	return result;
}


function get_pass_courses(pass_score,last_sem_id,courses){
	var res=[];
	for(var i = 0,course;course=courses[i];i++){
		if(course.sem_id==0||(course.sem_id!=last_sem_id&&check_pass(pass_score,course.score)))
			res.push(course);
	}
	return res;
}
function check_pass(pass_score,score){
	return score=="通過" || parseInt(score)>=pass_score
}
function get_sem_name(sem_id){
	sem_id-=1;
	var begin_year=99;
	begin_year+=Math.floor(sem_id/3);
	var half;
	switch(sem_id%3){
		case 0:
			half="上";
			break;
		case 1:
			half="下";
			break;
		case 3:
			half="暑";
	}
	return begin_year.toString()+half;
}
function get_cf_list(cfs,course){
	var res=[];
	for(var i = 0,cf;cf=cfs[i];i++){
		_get_course_cf(res,null,cf,course);
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

	return res;
}
function join_cf_courses(cf,courses){
	var res=[];
	for(var i = 0,course;course=courses[i];i++){
		if(course.cf_id==cf.id)
			res.push(course);
	}
	return res;
}
function check_course_match(uc,cf){
	for(var i = 0,course;course=cf.courses[i];i++){
		if(uc.course_id==course.id)
			return true;
	}
	//check course_group
	for(var i = 0,cg;cg=cf.course_groups[i];i++){
		for(var j = 0,course;course=cg.courses[j];j++){
		if(uc.course_id==course.id)
			return true;
		}
	}
	
	return false;
}
function _get_course_cf(res,parent_cf,cf,course){
	if(cf.cf_type<3){
		if(check_course_match(course,cf)){
			var name=parent_cf ? parent_cf.cf_name+" - "+cf.cf_name : cf.cf_name;
			res.push({id:cf.id,name:name});
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
	//console.log(user_courses[0].name);
	for(var j=0, user_course;user_course=user_courses[j];j++){
		if(course.id==user_course.course_id)   // TODO : score judge
			return true;
	}
	return false;
}

// for bottom node, check match
function _cf_course_match(user_courses, cf){
	var match_credit = 0, c_match=true ;
	var joined_courses=join_cf_courses(cf,user_courses);
	for(var i = 0,cf_course;cf_course=cf.courses[i];i++){ // for each cf course
		//console.log(cf_course.name);
		if(_check_user_course(joined_courses, cf_course)){
			match_credit += cf_course.credit ;
			//console.log(cf_course.name);
		}else{
			c_match = false ;
		}
	}
	//console.log('all_match1 '+c_match);
	var cg_match = true ;
	if(cf.course_groups){
		for(var i = 0,course_group;course_group=cf.course_groups[i];i++){ // for each cg
			var local_match = false ;
			for(var j=0, cg_course; cg_course=course_group.courses[j];j++){
				if(_check_user_course(joined_courses, cg_course)){
					match_credit += cg_course.credit ;
					local_match = true ;
					//console.log(cg_course.name);
					break ;
				}	
			}
			if(!local_match)
				cg_match = false ;
		}
	}	
	//console.log('all_match2 '+cg_match);
	return {match_credit: match_credit, all_match: (c_match && cg_match)} ;
}

function check_cf(user_courses,cf){
	//console.log(user_courses);
	
	switch(cf.cf_type){
		case 1:
			//console.log('[必修] cf_name : '+cf.cf_name) ;
			var res=_cf_course_match(user_courses, cf) ;
			return {match_credit: res.match_credit, result: res.all_match};
			
			break;
		case 2:
		//	console.log('[x選y] cf_name : '+cf.cf_name) ;
			var res = _cf_course_match(user_courses, cf) ;
			var match = (res.match_credit >= cf.credit_need) ? true : false;
			//console.log("xy result "+res.match_credit);
			return {match_credit: res.match_credit, result: match}; 		
			break;
		case 3:
		//	console.log('[領域群組] cf_name : '+cf.cf_name) ;
			var match_credit = 0, match_field = 0 ;
			for(var i = 0, sub_cf;sub_cf=cf.child_cf[i];i++){
				var res = check_cf(user_courses, sub_cf) ;
				match_credit += res.match_credit ;
				if(res.result)
					match_field++ ;
			}
			var match = (match_field >= cf.field_need && match_credit >= cf.credit_need) ? true : false ;	
			return {match_credit: match_credit, result: match}; 
			break;
		case 4:
		//	console.log('[領域] cf_name : '+cf.cf_name) ;
			var match_credit = 0, match = true;
			var credit_all = 0 ;
			for(var i = 0, sub_cf; sub_cf=cf.child_cf[i]; i++){
				credit_all += sub_cf.credit_need ;
			}
			
			for(var i = 0, sub_cf; sub_cf=cf.child_cf[i]; i++){
				if(sub_cf.credit_need==0)
					sub_cf.credit_need = cf.credit_need - credit_all ;
				var res = check_cf(user_courses, sub_cf) ;
				match_credit += res.match_credit ;
				if(!res.result) 
					match = false ;
			}
			
			return {match_credit: match_credit, result: match}; 
			break;
	}
}

function parse_cf_tree(cfs,user_courses,maxColSpan){
	var res="";
	
	for(var i = 0,cf;cf=cfs[i];i++){
		//res+='<tr class="row">';
		res+=get_node_data(cf,user_courses,maxColSpan);
		//res+="</tr>"
	}
	
	return res;
}
function get_node_data(cf,user_courses,maxColSpan){
	var res="";
	if(cf.cf_type==3){
		if(cf.child_cf){
			res+='<tr class="row">';
			res+='<td rowspan="2">'+cf.cf_name+"</td>";
			for(var i = 0,_cf;_cf=cf.child_cf[i];i++){
				res+="<td class='text-center'>"+_cf.cf_name+"</td>";
			}
			res+="</tr><tr class='row'>";
			for(var i = 0,_cf;_cf=cf.child_cf[i];i++){
				res+="<td class='text-center'>";
				var check=check_cf(user_courses,_cf);
				if(check["result"])
					res+=green_check();
				else
					res+=check["match_credit"]+"/"+_cf.credit_need;
				res+="</td>";
			}
			res+="</tr>";
		}
	}
	else{
		res+="<tr class='row'><td class='col-md-2'><a href='javascript:void(0);' onclick='show_list("+JSON.stringify(cf,null,4)+")'>"+cf.cf_name+"</a></td>";
		res+="<td class='col-md-10 text-center' colspan='"+maxColSpan+"'>";
		
		var check=check_cf(user_courses,cf);
		if(check["result"])
			res+=green_check();
		else res+=check["match_credit"]+"/"+cf.credit_need;
		res+="</td></tr>";
	}
	return res;
}