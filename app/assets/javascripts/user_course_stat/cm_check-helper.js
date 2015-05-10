/*
 * Copyright (C) 2014 NCTU+
 *
 * For user/statistics
 * 此檔案是產生課程地圖打勾的HTML所需
 *
 * Modified at 2015/5/11
 */

function parse_cf_tree(cfs,user_courses,maxColSpan){//產生check的table html
	var res="";
	for(var i = 0,cf;cf=cfs[i];i++){
		res+=get_node_data(cf,user_courses,maxColSpan);
	}
	return res;
}

function get_node_data(cf,user_courses,maxColSpan){
	var str="";
	var result=[];
	if(cf.cf_type==3){
		if(cf.child_cf){
			str+='<tr class="row">';
			str+='<td rowspan="2">'+cf.cf_name+"</td>";
			for(var i = 0,_cf;_cf=cf.child_cf[i];i++){
				str+="<td class='text-center'>"+_cf.cf_name+"</td>";
			}
			str+="</tr><tr class='row'>";
			for(var i = 0,_cf;_cf=cf.child_cf[i];i++){
				str+="<td class='text-center'>";
				var check=check_cf(user_courses,_cf);
				
				if(check["result"])
					str+=green_check();
				else
					str+=check["match_credit"]+"/"+_cf.credit_need;
				str+="</td>";
			}
			str+="</tr>";
		}
	}
	else{
		str+="<tr class='row'><td class='col-md-2'>"+cf.cf_name+"</td>";
		str+="<td class='col-md-10 text-center' colspan='"+maxColSpan+"'>";
		
		var check=check_cf(user_courses,cf);

		if(check["result"])
			str+=green_check();
		else str+=check["match_credit"]+"/"+cf.credit_need;
		str+="</td></tr>";
	}
	return str;
}
