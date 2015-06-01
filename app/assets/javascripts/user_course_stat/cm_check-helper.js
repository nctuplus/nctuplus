/*
 * Copyright (C) 2014 NCTU+
 *
 * For user/statistics
 * 此檔案是產生課程地圖打勾的HTML所需
 *
 * Modified at 2015/5/11
 */

function genCosMapCheckGrids(cfs,user_courses,maxColSpan){//產生check的table html
	var res="";
	for(var i = 0,cf;cf=cfs[i];i++){
		res+=genRow(cf,user_courses,maxColSpan);
	}
	return res;
}

function genRow(cf,user_courses,maxColSpan){
	var str="";
	var result=[];
	if(cf.cf_type==3){
		if(cf.child_cf){
			var result=checkCf(user_courses,cf)
			console.log(result);
			str+='<tr class="row">';
			str+='<td class="text-center">'+cf.cf_name+"</td>";
			for(var i = 0,res;res=result.sub_res[i];i++){
				str+="<td class='text-center'>"+res.cf_name+"</td>";
			}
			str+="</tr><tr class='row'>";
			str+="<td class='text-center'>";
			if(result["result"])
				str+=green_check();
			else
				str+=result.match_field+"/"+cf.field_need
			res+="</td>";
			for(var i = 0,res;res=result.sub_res[i];i++){
				str+="<td class='text-center'>";
				if(res.result)
					str+=green_check();
				else
					str+=res.res_text;
				str+="</td>";
			}
			str+="</tr>";
		}
	}
	else{
		str+="<tr class='row'><td class='col-md-2 text-center'>"+cf.cf_name+"</td>";
		str+="<td class='col-md-10 text-center' colspan='"+maxColSpan+"'>";
		var check=checkCf(user_courses,cf);
		if(check["result"])
			str+=green_check();
		else str+=check["match_credit"]+"/"+cf.credit_need;
		str+="</td></tr>";
	}
	return str;
}
